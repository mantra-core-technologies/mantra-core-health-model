#!/usr/bin/env python3
"""Contrato del patch 2026-10-29_infraestructura_f2_practice.sql (infraestructura F2).

Dos capas:

1. ESTÁTICAS (siempre corren): el patch es idempotente por construcción, no destruye datos,
   los UUID literales son los `deterministicId('practice:<NOMBRE>')` de la API y coinciden en
   el patch, en diagram_14 y en diagram_33, y el .puml declara las columnas que el patch agrega.

2. CONTRA POSTGRES REAL (corren si `SALUD_PG_DATABASE` nombra una base con F1 + F1b aplicados
   y el usuario libpq —PGHOST/PGPORT/PGUSER/PGPASSWORD— es superusuario; si no, se omiten con
   el motivo a la vista). NO modifican esa base: cada escenario corre dentro de
   `BEGIN … ROLLBACK`; primero retira los objetos de F2 (DDL transaccional), vuelve a aplicar
   el patch sin su BEGIN/COMMIT y ejecuta los casos con SAVEPOINT. Cubren: dos aplicaciones sin
   cambios, backfill condicional de los ejes, aislamiento entre tenants (FK compuestas y RLS),
   CHECK, EXCLUDE, único parcial, guarda de inmutabilidad y precondiciones que abortan.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import uuid
from pathlib import Path

import pytest

MODEL = Path(__file__).resolve().parents[2]
PATCH = MODEL / "SQL" / "patches" / "2026-10-29_infraestructura_f2_practice.sql"
D14 = MODEL / "Mantra Core Health Context" / "modules" / "diagram_14_practice.puml"
D33 = MODEL / "Mantra Core Health Context" / "modules" / "diagram_33_integrity.puml"

# HEALTH_UUID_NAMESPACE de mantra-core-health-api/src/common/constants/concepts.ts;
# deterministicId(key) = uuid5(namespace, key).
API_NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")


def cid(name: str) -> str:
    """Id determinista del concepto `practice:<name>` (practice.concepts.ts)."""
    return str(uuid.uuid5(API_NAMESPACE, f"practice:{name}"))


LITERALS = {
    "SPACE_OP_AVAILABLE": "7ce5a926-1c46-56d4-8ca8-679e7429fa1d",
    "HYG_CLEAN": "7874b037-177f-5cac-adad-e7ba679d9ad3",
    "HYG_INSPECTED": "29482974-499d-5b09-92a8-95fcfa0e521e",
    "SPACE_ACTIVE": "9c27f70c-9472-5bee-92e7-78e209d581c7",
    "ISO_NONE": "f2ead1d9-06f7-59a3-b26f-a3642a164f47",
    "BLOCK_MAINTENANCE": "b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0",
    "CLN_PENDING": "c0c5918f-cf97-51e1-9ede-72d856e61c93",
    "CLN_IN_PROGRESS": "60ff8df8-4ba5-591c-b092-e8da81187539",
    "CLN_DONE": "334b9e1f-b123-5477-a22e-2dd1b838c2fa",
}

UUID_RE = re.compile(r"\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b")
F2_COLUMNS = (
    "availability_reason_concept_id", "availability_expected_until", "availability_changed_at",
    "hygiene_status_concept_id", "hygiene_changed_at", "terminal_cleaning_required",
    "isolation_concept_id", "isolation_organism_text", "isolation_changed_at", "ops_version",
)
NEW_TABLES = (
    ("practice", "care_space_status_events"), ("practice", "care_space_blocks"),
    ("practice", "cleaning_orders"), ("audit", "care_space_blocks_history"),
    ("audit", "cleaning_orders_history"),
)


def executable_sql(text: str) -> str:
    """El patch sin comentarios `--` (los UUID del encabezado no cuentan como predicados)."""
    return "\n".join(re.sub(r"--.*$", "", line) for line in text.splitlines())


# ═══════════════════════════════════════════════════════════════ 1 · estáticas
class TestStaticContract:
    @classmethod
    def setup_class(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")
        cls.code = executable_sql(cls.sql)

    def test_literals_are_the_api_deterministic_ids(self) -> None:
        for name, literal in LITERALS.items():
            assert cid(name) == literal, f"practice:{name} ya no coincide con el literal documentado"

    def test_every_uuid_in_the_executable_sql_is_a_known_concept(self) -> None:
        found = set(UUID_RE.findall(self.code))
        assert found, "el patch debería usar los UUID literales"
        assert found <= set(LITERALS.values()), found - set(LITERALS.values())

    def test_literals_agree_with_the_model_sources(self) -> None:
        d14, d33 = D14.read_text(encoding="utf-8"), D33.read_text(encoding="utf-8")
        for name in ("CLN_PENDING", "CLN_IN_PROGRESS", "CLN_DONE"):
            assert LITERALS[name] in d14 and LITERALS[name] in self.code
        assert LITERALS["BLOCK_MAINTENANCE"] in d33 and LITERALS["BLOCK_MAINTENANCE"] in self.code
        for name in ("HYG_CLEAN", "HYG_INSPECTED", "SPACE_ACTIVE", "ISO_NONE", "SPACE_OP_AVAILABLE"):
            assert LITERALS[name] in self.code

    def test_the_puml_declares_every_column_the_patch_adds(self) -> None:
        block = D14.read_text(encoding="utf-8").split("entity care_spaces {", 1)[1].split("\n}\n", 1)[0]
        for column in F2_COLUMNS:
            assert re.search(rf"^\s+\*?\s*{column} :", block, re.M), column
            assert f'ADD COLUMN IF NOT EXISTS "{column}"' in self.sql, column

    def test_columns_tables_and_indexes_are_if_not_exists(self) -> None:
        assert not re.search(r"ADD COLUMN (?!IF NOT EXISTS)", self.code)
        assert not re.search(r"CREATE TABLE (?!IF NOT EXISTS)", self.code)
        assert not re.search(r"CREATE (UNIQUE )?INDEX (?!IF NOT EXISTS)", self.code)

    def test_every_foreign_key_tolerates_a_second_pass(self) -> None:
        adds = len(re.findall(r"ADD CONSTRAINT \"fk_", self.code))
        guarded = len(re.findall(r"EXCEPTION WHEN duplicate_object THEN NULL", self.code))
        assert adds > 0 and guarded >= adds

    def test_the_patch_destroys_nothing(self) -> None:
        for forbidden in (r"\bDROP TABLE\b", r"^\s*TRUNCATE\b", r"\bDELETE FROM\b", r"\bDROP COLUMN\b",
                          r"\bDROP SCHEMA\b", r"ALTER COLUMN [^\n]* TYPE\b"):
            assert not re.search(forbidden, self.code, re.I | re.M), forbidden

    def test_it_runs_in_one_transaction_and_opens_the_system_context(self) -> None:
        lines = [l.strip() for l in self.code.splitlines()]
        assert lines.count("BEGIN;") == 1 and lines.count("COMMIT;") == 1
        assert "SET LOCAL app.system_context = 'true';" in lines

    def test_contract_object_names(self) -> None:
        for name in (
            "ex_care_space_blocks_time", "ck_care_space_blocks_maintenance_eta",
            "ck_care_space_blocks_end_after_start", "ux_cleaning_orders_one_open_per_space",
            "ck_cleaning_orders_inspector_differs", "ck_care_space_status_events_v2_code",
            "audit.care_space_blocks_history", "audit.cleaning_orders_history",
        ):
            assert name in self.sql, name
        assert "'C','H','I','K','O','U','R'" in self.sql
        assert "tstzrange(\"starts_at\", \"ended_at\", '[)')" in self.sql
        assert '"cancelled_at" IS NULL' in self.sql

    def test_events_are_append_only_and_every_table_gets_rls(self) -> None:
        assert 'integrity"."forbid_mutation"' in self.sql
        assert "BEFORE UPDATE OR DELETE ON \"practice\".\"care_space_status_events\"" in self.sql
        for schema, table in NEW_TABLES:
            assert f"'{schema}.{table}'" in self.sql, table

    def test_hot_files_are_not_edited_by_this_change(self) -> None:
        # El patch no debe depender de nada que solo regenera el integrador.
        for hot in ("apply_all.sql", "SHA256SUMS", "model-manifest", "_generation_report"):
            assert hot not in self.code


@pytest.fixture(scope="module")
def generated(tmp_path_factory):
    import contextlib
    import io
    import sys
    from unittest import mock

    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    import gen_ddl
    import gen_integrity

    out = tmp_path_factory.mktemp("sql")
    codes = sorted({p.stem.split("_")[1] for p in gen_ddl.PUML_DIR.glob("diagram_*.puml")})
    with contextlib.redirect_stdout(io.StringIO()), \
            mock.patch.object(gen_ddl, "OUT_DIR", out), \
            mock.patch.object(gen_integrity, "SQL_DIR", out), \
            mock.patch.object(gen_integrity, "OUT", out / "_integrity"):
        registry = gen_ddl.build_registry(codes)
        pk_map = gen_ddl.build_pk_map(codes)
        for code in ("10", "14"):
            gen_ddl.emit(code, [], registry, pk_map)
        ents, _rels, _notes = gen_integrity.parse_module33()
        gen_integrity.resolve_owners(ents, registry)
        gen_integrity.write_functions()
        gen_integrity.write_constraints(ents)
    return {
        "tables": (out / "14_practice" / "02_tables.sql").read_text(encoding="utf-8")
        + (out / "10_audit" / "02_tables.sql").read_text(encoding="utf-8"),
        "indexes": (out / "14_practice" / "04_indexes.sql").read_text(encoding="utf-8")
        + (out / "10_audit" / "04_indexes.sql").read_text(encoding="utf-8"),
        "fks": "".join((out / d / f).read_text(encoding="utf-8")
                       for d in ("14_practice", "10_audit") for f in ("03_fk_intra.sql", "90_fk_deferred.sql")),
        "constraints": (out / "14_practice" / "05_constraints.sql").read_text(encoding="utf-8"),
    }



class TestPatchMatchesGeneratedDDL:
    """El patch copia —no reescribe— lo que gen_ddl.py / gen_integrity.py emiten de los .puml:
    si alguien cambia el .puml y no el patch (o al revés), esta clase lo delata. Genera en un
    directorio temporal; no toca SQL/."""

    @staticmethod
    def norm(text: str) -> str:
        return re.sub(r"\s+", " ", text).strip()

    def test_tables_are_the_generated_ones(self, generated) -> None:
        patch = self.norm(PATCH.read_text(encoding="utf-8"))
        for schema, table in NEW_TABLES:
            m = re.search(rf'CREATE TABLE IF NOT EXISTS "{schema}"\."{table}" \(.*?\n\);', generated["tables"], re.S)
            assert m, f"{schema}.{table} ya no sale de los .puml"
            assert self.norm(m.group(0)) in patch, f"{schema}.{table}: el patch difiere del DDL generado"

    def test_indexes_are_the_generated_ones_and_none_is_missing(self, generated) -> None:
        names = r"(care_space_status_events|care_space_blocks|cleaning_orders|cleaning_orders_history|care_space_blocks_history)"
        wanted = [l for l in generated["indexes"].splitlines()
                  if re.search(rf'"(practice|audit)"\."{names}"', l)
                  or re.search(r'"(ix_care_spaces_(availability|hygiene|isolation)\w*|ux_care_spaces_site_id_id)"', l)]
        assert len(wanted) == 54, len(wanted)
        patch = PATCH.read_text(encoding="utf-8")
        missing = [l for l in wanted if l not in patch]
        assert not missing, missing[:3]

    def test_simple_foreign_keys_are_the_generated_ones(self, generated) -> None:
        pat = re.compile(r'ADD CONSTRAINT "(fk_[a-z0-9_]+)" FOREIGN KEY \("([a-z_]+)"\)\s+REFERENCES ("[a-z_]+"\."[a-z_]+") \("id"\)')
        gen = {}
        for m in pat.finditer(generated["fks"]):
            tbl_ctx = generated["fks"][:m.start()].rsplit("ALTER TABLE ", 1)[1].split("\n", 1)[0]
            if re.search(r'"(care_space_status_events|care_space_blocks|cleaning_orders|care_space_blocks_history|cleaning_orders_history)"', tbl_ctx) \
                    or m.group(1) in ("fk_care_spaces_availability_reason_concept_id", "fk_care_spaces_hygiene_status_concept_id",
                                      "fk_care_spaces_isolation_concept_id"):
                gen[m.group(1)] = (tbl_ctx, m.group(2), m.group(3))
        assert len(gen) == 45, len(gen)
        patch = self.norm(PATCH.read_text(encoding="utf-8"))
        for name, (tbl, col, ref) in gen.items():
            expected = self.norm(f'ALTER TABLE {tbl} ADD CONSTRAINT "{name}" FOREIGN KEY ("{col}") REFERENCES {ref} ("id");')
            assert expected in patch, name

    def test_integrity_rules_are_the_generated_ones(self, generated) -> None:
        patch = self.norm(PATCH.read_text(encoding="utf-8"))
        gen = self.norm(generated["constraints"])
        for name in ("ck_care_space_status_events_v2_code", "ck_care_space_blocks_maintenance_eta",
                     "ck_care_space_blocks_end_after_start", "ck_cleaning_orders_inspector_differs"):
            m = re.search(rf'ALTER TABLE "practice"\."\w+" ADD CONSTRAINT "{name}" CHECK .*?;', gen)
            assert m and m.group(0) in patch, name
        m = re.search(r'ALTER TABLE "practice"\."care_space_blocks" ADD CONSTRAINT "ex_care_space_blocks_time" EXCLUDE .*?;', gen)
        assert m and m.group(0) in patch
        m = re.search(r'CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "practice"\."care_space_status_events" .*?;', gen)
        assert m and m.group(0) in patch


# ═══════════════════════════════════════════════════════ 2 · contra Postgres real
DB = os.environ.get("SALUD_PG_DATABASE")


def _psql(script: str, timeout: int = 600) -> tuple[str, str, int]:
    proc = subprocess.run(
        ["psql", "-X", "-q", "-At", "-d", DB, "-v", "VERBOSITY=verbose", "-f", "-"],
        input=script, text=True, encoding="utf-8", capture_output=True, timeout=timeout,
        env={**os.environ, "PGCLIENTENCODING": "UTF8", "PGOPTIONS": "-c lc_messages=C"},
    )
    return proc.stdout, proc.stderr, proc.returncode


def _db_unavailable_reason() -> str | None:
    if not DB:
        return "SALUD_PG_DATABASE sin definir (base con F1+F1b aplicados); se omiten las pruebas contra Postgres"
    if shutil.which("psql") is None:
        return "psql no está en el PATH"
    out, err, rc = _psql("SELECT current_setting('is_superuser') || '|' || (to_regclass('practice.space_unit_assignments') IS NOT NULL)"
                         " || '|' || (to_regprocedure('audit.structure_history_close_only()') IS NOT NULL);")
    if rc != 0:
        return f"no se pudo conectar a {DB}: {err.strip()[:200]}"
    if out.strip() != "on|true|true":
        return f"{DB} necesita superusuario y F1+F1b aplicados (obtuve {out.strip()!r})"
    return None


REASON = _db_unavailable_reason()
needs_pg = pytest.mark.skipif(REASON is not None, reason=REASON or "")


def patch_body(text: str | None = None) -> str:
    """El patch sin su BEGIN/COMMIT: lo que corre dentro de la transacción del escenario.
    `text` permite correr una copia mutada (pruebas de mutación)."""
    lines = (PATCH.read_text(encoding="utf-8") if text is None else text).splitlines()
    kept = [l for l in lines if l.strip() not in ("BEGIN;", "COMMIT;")]
    assert len(lines) - len(kept) == 2
    return "\n".join(kept)


RESET = """
DROP TABLE IF EXISTS audit.care_space_blocks_history, audit.cleaning_orders_history,
    practice.care_space_status_events, practice.care_space_blocks, practice.cleaning_orders CASCADE;
DROP INDEX IF EXISTS practice.ux_care_spaces_site_id_id;
ALTER TABLE practice.care_spaces
    DROP COLUMN IF EXISTS availability_reason_concept_id, DROP COLUMN IF EXISTS availability_expected_until,
    DROP COLUMN IF EXISTS availability_changed_at, DROP COLUMN IF EXISTS hygiene_status_concept_id,
    DROP COLUMN IF EXISTS hygiene_changed_at, DROP COLUMN IF EXISTS terminal_cleaning_required,
    DROP COLUMN IF EXISTS isolation_concept_id, DROP COLUMN IF EXISTS isolation_organism_text,
    DROP COLUMN IF EXISTS isolation_changed_at, DROP COLUMN IF EXISTS ops_version;
"""

FINGERPRINT = """
SELECT '@@RES {name}|' || md5(string_agg(x, E'\\n' ORDER BY x)) || '|' || count(*) FROM (
  WITH t(sch, tab) AS (VALUES ('practice','care_spaces'),('practice','care_space_status_events'),
        ('practice','care_space_blocks'),('practice','cleaning_orders'),
        ('audit','care_space_blocks_history'),('audit','cleaning_orders_history'))
  SELECT 'col|'||c.table_schema||'.'||c.table_name||'.'||c.column_name||'|'||c.data_type||'|'||c.is_nullable||'|'||coalesce(c.column_default,'')
    FROM information_schema.columns c JOIN t ON t.sch=c.table_schema AND t.tab=c.table_name
  UNION ALL SELECT 'con|'||conrelid::regclass||'|'||conname||'|'||pg_get_constraintdef(oid) FROM pg_constraint
    WHERE conrelid IN (SELECT (sch||'.'||tab)::regclass FROM t)
  UNION ALL SELECT 'idx|'||schemaname||'|'||indexname||'|'||indexdef FROM pg_indexes WHERE (schemaname,tablename) IN (SELECT sch,tab FROM t)
  UNION ALL SELECT 'trg|'||tgrelid::regclass||'|'||tgname||'|'||pg_get_triggerdef(oid) FROM pg_trigger
    WHERE NOT tgisinternal AND tgrelid IN (SELECT (sch||'.'||tab)::regclass FROM t)
  UNION ALL SELECT 'pol|'||schemaname||'.'||tablename||'|'||policyname||'|'||coalesce(qual,'')||'|'||coalesce(with_check,'')
    FROM pg_policies WHERE (schemaname,tablename) IN (SELECT sch,tab FROM t)
  UNION ALL SELECT 'rls|'||c.oid::regclass||'|'||c.relrowsecurity||'|'||c.relforcerowsecurity FROM pg_class c
    WHERE c.oid IN (SELECT (sch||'.'||tab)::regclass FROM t)
  UNION ALL SELECT 'acl|'||c.oid::regclass||'|'||coalesce(c.relacl::text,'') FROM pg_class c
    WHERE c.oid IN (SELECT (sch||'.'||tab)::regclass FROM t)
  UNION ALL SELECT 'colacl|'||c.oid::regclass||'|'||a.attname||'|'||a.attacl::text FROM pg_class c
    JOIN pg_attribute a ON a.attrelid=c.oid WHERE a.attacl IS NOT NULL AND c.oid IN (SELECT (sch||'.'||tab)::regclass FROM t)
) f(x);
"""

# ------------------------------------------------------------------ fixtures de datos
TEST_NS = uuid.UUID("11111111-2222-5333-8444-555555555555")


def u(name: str) -> str:
    return str(uuid.uuid5(TEST_NS, name))


TA, TB = u("tenant-A"), u("tenant-B")
PA, PB = u("practice-A"), u("practice-B")
SITE_A1, SITE_A2, SITE_B1 = u("site-A1"), u("site-A2"), u("site-B1")
UNIT_A, UNIT_B = u("unit-A"), u("unit-B")
SP_A1, SP_A2, SP_A3, SP_B1 = u("space-A1"), u("space-A2"), u("space-A3-en-sede-A2"), u("space-B1")
USER1, USER2, USER3 = u("user-1"), u("user-2"), u("user-3")

# Conceptos que el patch NO conoce (los siembra la API); acá sólo hacen falta las filas.
CONCEPT_NAMES = [
    "GEN_STATUS", "GEN_TYPE", "GEN_OP", "BLOCK_CLINICAL", "BLOCK_ADMIN", "BLOCK_RSN_PREVENTIVE_MAINTENANCE",
    "BLOCK_RSN_STAFF_SHORTAGE", "CLN_INSPECTED", "CLN_REJECTED", "CLN_CANCELLED", "CLEAN_ROUTINE",
    "CLEAN_TERMINAL", "CLN_TRG_MANUAL", "CLN_PRIO_ROUTINE", "AXIS_AVAILABILITY", "AXIS_HYGIENE",
    "SPACE_OP_BLOCKED_CLINICAL", "SRC_MANUAL", "SPACE_OP_CLOSED",
    # ciclo de vida y una higiene «operada» para el escenario del backfill de higiene
    "SPACE_ACTIVE", "SPACE_PLANNED", "SPACE_SUSPENDED", "HYG_DIRTY",
]
ALWAYS_CONCEPTS = CONCEPT_NAMES + ["BLOCK_MAINTENANCE", "CLN_PENDING", "CLN_IN_PROGRESS", "CLN_DONE"]
BACKFILL_CONCEPTS = ["SPACE_OP_AVAILABLE", "HYG_CLEAN", "HYG_INSPECTED", "ISO_NONE"]


def c(name: str) -> str:
    return cid(name)


def concept_rows(names: list[str]) -> str:
    rows = ",\n".join(
        f"('{c(n)}', '{u('csv')}', '{n}', '{n}', now(), now(), 1)" for n in names
    )
    return ("INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, created_at, updated_at, row_version)\n"
            f"VALUES {rows};\n")


def fixtures(*, concepts: list[str]) -> str:
    """Dos tenants con su cadena completa. FK ignoradas sólo al sembrar (replica); los casos
    corren con las FK activas."""
    g = c("GEN_STATUS")
    sp = []
    for sid, site, unit, tenant, code in (
        (SP_A1, SITE_A1, UNIT_A, TA, "A1"), (SP_A2, SITE_A1, UNIT_A, TA, "A2"),
        (SP_A3, SITE_A2, UNIT_A, TA, "A3"), (SP_B1, SITE_B1, UNIT_B, TB, "B1"),
    ):
        sp.append(f"('{sid}', '{site}', '{unit}', '{code}', '{code}', '{c('GEN_TYPE')}', '{g}', now(), now(), 1, '{tenant}')")
    return (
        "SET LOCAL session_replication_role = replica;\n"
        + concept_rows(concepts)
        + f"INSERT INTO iam.users (id, status_concept_id, display_name, created_at, updated_at, row_version) VALUES "
          f"('{USER1}','{g}','u1',now(),now(),1),('{USER2}','{g}','u2',now(),now(),1),('{USER3}','{g}','u3',now(),now(),1);\n"
        + "INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at, row_version) VALUES "
        + ",".join(f"('{t}','{n}','{g}','{n}','{g}','{g}','{g}',now(),now(),1)" for t, n in ((TA, "TA"), (TB, "TB"))) + ";\n"
        + "INSERT INTO practice.practices (id, tenant_id, code, name, type_concept_id, admin_user_id, status_concept_id, created_at, updated_at, row_version) VALUES "
        + ",".join(f"('{p}','{t}','{n}','{n}','{g}','{USER1}','{g}',now(),now(),1)" for p, t, n in ((PA, TA, "PA"), (PB, TB, "PB"))) + ";\n"
        + "INSERT INTO practice.practice_sites (id, practice_id, code, name, site_type_concept_id, status_concept_id, created_at, updated_at, row_version, tenant_id) VALUES "
        + ",".join(f"('{s}','{p}','{n}','{n}','{g}','{g}',now(),now(),1,'{t}')" for s, p, n, t in
                   ((SITE_A1, PA, "SA1", TA), (SITE_A2, PA, "SA2", TA), (SITE_B1, PB, "SB1", TB))) + ";\n"
        + "INSERT INTO practice.clinical_units (id, practice_site_id, code, name, unit_type_concept_id, status_concept_id, created_at, updated_at, row_version, tenant_id) VALUES "
        + ",".join(f"('{un}','{s}','{n}','{n}','{g}','{g}',now(),now(),1,'{t}')" for un, s, n, t in
                   ((UNIT_A, SITE_A1, "UA", TA), (UNIT_B, SITE_B1, "UB", TB))) + ";\n"
        + "INSERT INTO practice.care_spaces (id, practice_site_id, clinical_unit_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, row_version, tenant_id) VALUES "
        + ",".join(sp) + ";\n"
        + "SET LOCAL session_replication_role = origin;\n"
    )


def t(hhmm: str) -> str:
    return f"timestamptz '2026-10-30 {hhmm}+00'"


def ev(i: str, tenant: str, site: str, space: str, v2: str = "C") -> str:
    return (f"INSERT INTO practice.care_space_status_events (id, tenant_id, practice_site_id, care_space_id, axis_concept_id, to_concept_id, "
            f"v2_0116_code, source_concept_id, occurred_at, created_at) VALUES ('{u(i)}','{tenant}','{site}','{space}',"
            f"'{c('AXIS_AVAILABILITY')}','{c('SPACE_OP_BLOCKED_CLINICAL')}','{v2}','{c('SRC_MANUAL')}', now(), now());")


def blk(i: str, tenant: str, space: str, start: str, end: str | None = None, *, kind: str = "BLOCK_CLINICAL",
        eta: str | None = None, cancelled: bool = False, reason: bool = True) -> str:
    return (f"INSERT INTO practice.care_space_blocks (id, tenant_id, care_space_id, kind_concept_id, reason_concept_id, starts_at, "
            f"expected_end_at, ended_at, cancelled_at, created_at, updated_at) VALUES ('{u(i)}','{tenant}','{space}','{c(kind)}',"
            f"{repr_uuid(c('BLOCK_RSN_STAFF_SHORTAGE')) if reason else 'NULL'},{t(start)},{t(eta) if eta else 'NULL'},"
            f"{t(end) if end else 'NULL'},{'now()' if cancelled else 'NULL'},now(),now());")


def repr_uuid(x: str) -> str:
    return f"'{x}'"


def order(i: str, tenant: str, site: str, space: str, status: str = "CLN_PENDING", *, unit: str | None = None,
          previous: str | None = None, finished_by: str | None = None, inspected_by: str | None = None,
          priority: bool = True) -> str:
    return (f"INSERT INTO practice.cleaning_orders (id, tenant_id, practice_site_id, care_space_id, clinical_unit_id, cleaning_type_concept_id, "
            f"trigger_concept_id, priority_concept_id, status_concept_id, requested_at, previous_order_id, finished_by_user_id, "
            f"inspected_by_user_id, created_at, updated_at) VALUES ('{u(i)}','{tenant}','{site}','{space}',"
            f"{repr_uuid(unit) if unit else 'NULL'},'{c('CLEAN_ROUTINE')}','{c('CLN_TRG_MANUAL')}',"
            f"{repr_uuid(c('CLN_PRIO_ROUTINE')) if priority else 'NULL'},'{c(status)}',now(),"
            f"{repr_uuid(u(previous)) if previous else 'NULL'},{repr_uuid(finished_by) if finished_by else 'NULL'},"
            f"{repr_uuid(inspected_by) if inspected_by else 'NULL'},now(),now());")


def hist(table: str, i: str, origin: str, tenant: str | None) -> str:
    col = "care_space_block_id" if table == "care_space_blocks_history" else "cleaning_order_id"
    cols = f"history_id, {col}, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at" + (", tenant_id" if tenant else "")
    vals = f"'{u(i)}','{u(origin)}',1,'{c('GEN_OP')}',now(),'{{}}'::jsonb,now()" + (f",'{tenant}'" if tenant else "")
    return f"INSERT INTO audit.{table} ({cols}) VALUES ({vals});"


def as_app(tenant: str | None, sql: str) -> str:
    """Corre `sql` como mantra_app (sin BYPASSRLS) con el tenant activo indicado."""
    ctx = f"SELECT set_config('app.current_tenant_id', '{tenant}', true);" if tenant else "SELECT set_config('app.current_tenant_id', '', true);"
    return f"SET LOCAL ROLE mantra_app;\n{ctx}\n{sql}"


# ------------------------------------------------------------------ ejecución de escenarios
class Probe:
    def __init__(self, name: str) -> None:
        self.name = name
        self.errors: list[tuple[str, str]] = []
        self.results: list[str] = []

    @property
    def code(self) -> str | None:
        """SQLSTATE del PRIMER error del caso (los siguientes son 25P02 de arrastre)."""
        return self.errors[0][0] if self.errors else None

    @property
    def message(self) -> str:
        return self.errors[0][1] if self.errors else ""


def run_script(setup: str, probes: list[tuple[str, str]]) -> dict[str, Probe]:
    """Una transacción: setup; luego cada caso dentro de su SAVEPOINT; ROLLBACK final."""
    script = ["\\set ON_ERROR_STOP off", "BEGIN;", setup, "\\warn @@SETUP_DONE"]
    for name, sql in probes:
        script += [f"\\warn @@PROBE {name}", "SAVEPOINT probe_sp;", sql, "ROLLBACK TO SAVEPOINT probe_sp;",
                   f"\\warn @@END {name}"]
    script += ["ROLLBACK;", "\\warn @@ALL_DONE"]
    out, err, rc = _psql("\n".join(script))
    assert "@@ALL_DONE" in err, f"el escenario no terminó (rc={rc}): {err[-1500:]}"
    pre_setup, rest = err.split("@@SETUP_DONE", 1)
    setup_errors = [ln for ln in pre_setup.splitlines() if "ERROR:" in ln]
    assert not setup_errors, "falló la preparación del escenario:\n" + "\n".join(setup_errors[:5])
    probes_out: dict[str, Probe] = {}
    current: Probe | None = None
    for line in rest.splitlines():
        m = re.match(r"@@PROBE (\S+)", line)
        if m:
            current = Probe(m.group(1))
            probes_out[current.name] = current
            continue
        if line.startswith("@@END"):
            current = None
            continue
        m = re.search(r"ERROR:\s+([0-9A-Z]{5}):\s+(.*)", line)
        if m and current is not None:
            current.errors.append((m.group(1), m.group(2)))
    for line in out.splitlines():
        m = re.match(r"@@RES ([^\s|]+)\|(.*)", line)
        if m and m.group(1) in probes_out:
            probes_out[m.group(1)].results.append(m.group(2))
        elif m:
            probes_out.setdefault(m.group(1), Probe(m.group(1))).results.append(m.group(2))
    return probes_out


def ok(p: Probe) -> None:
    assert p.code is None, f"{p.name}: no debía fallar y falló con {p.code}: {p.message}"


def rejected(p: Probe, code: str, fragment: str = "") -> None:
    assert p.code == code, f"{p.name}: esperaba {code}, obtuve {p.code}: {p.message}"
    assert fragment in p.message, f"{p.name}: el mensaje {p.message!r} no menciona {fragment!r}"


# ═════════════════════════════════════════════ escenario A · comportamiento tras el patch
def _behavior_probes() -> list[tuple[str, str]]:
    P: list[tuple[str, str]] = []

    def add(name: str, sql: str) -> None:
        P.append((name, sql))

    # --- eventos A20 (append-only)
    add("event_valid_insert", ev("e-new", TA, SITE_A1, SP_A1))
    add("event_all_v2_codes", "\n".join(ev(f"e-{k}", TA, SITE_A1, SP_A1, k) for k in "CHIKOUR"))
    add("event_v2_invalid", ev("e-bad", TA, SITE_A1, SP_A1, "X"))
    add("event_update_rejected", f"UPDATE practice.care_space_status_events SET reason_text = 'x' WHERE id = '{u('e-A')}';")
    add("event_delete_rejected", f"DELETE FROM practice.care_space_status_events WHERE id = '{u('e-A')}';")
    add("event_cross_tenant_space", ev("e-x1", TB, SITE_B1, SP_A1))
    add("event_cross_tenant_site", ev("e-x2", TA, SITE_B1, SP_A1))
    add("event_site_is_not_the_spaces_site", ev("e-x3", TA, SITE_A2, SP_A1))
    add("event_missing_target_concept", ev("e-x4", TA, SITE_A1, SP_A1).replace(f"'{c('SPACE_OP_BLOCKED_CLINICAL')}'", "NULL"))
    add("event_app_cannot_update", as_app(TA, f"UPDATE practice.care_space_status_events SET reason_text = 'x' WHERE id = '{u('e-A')}';"))
    add("event_app_cannot_delete", as_app(TA, f"DELETE FROM practice.care_space_status_events WHERE id = '{u('e-A')}';"))
    add("event_app_insert_own_tenant", as_app(TA, ev("e-app", TA, SITE_A1, SP_A1)))
    add("event_app_insert_other_tenant_rls", as_app(TA, ev("e-app2", TB, SITE_B1, SP_B1)))

    # --- aislamiento por RLS: cada tenant ve sólo lo suyo
    for table, key in (("practice.care_space_status_events", "e"), ("practice.care_space_blocks", "b"),
                       ("practice.cleaning_orders", "o"), ("audit.care_space_blocks_history", "hb"),
                       ("audit.cleaning_orders_history", "ho")):
        short = table.split(".")[1]
        for who, tenant, other in (("A", TA, TB), ("B", TB, TA)):
            add(f"rls_{short}_{who}_sees_only_own",
                as_app(tenant, f"SELECT '@@RES rls_{short}_{who}_sees_only_own|' || count(*) FILTER (WHERE tenant_id = '{tenant}') "
                               f"|| '/' || count(*) FILTER (WHERE tenant_id = '{other}') FROM {table};"))
        add(f"rls_{short}_no_context_sees_nothing",
            as_app(None, f"SELECT '@@RES rls_{short}_no_context_sees_nothing|' || count(*) FROM {table};"))
    add("rls_blocks_cannot_update_other_tenant",
        as_app(TA, f"WITH x AS (UPDATE practice.care_space_blocks SET end_note = 'hack' WHERE id = '{u('b-B')}' RETURNING 1) "
                   f"SELECT '@@RES rls_blocks_cannot_update_other_tenant|' || count(*) FROM x;"))
    add("rls_orders_cannot_delete_other_tenant",
        as_app(TA, f"WITH x AS (DELETE FROM practice.cleaning_orders WHERE id = '{u('o-B')}' RETURNING 1) "
                   f"SELECT '@@RES rls_orders_cannot_delete_other_tenant|' || count(*) FROM x;"))
    add("rls_blocks_app_insert_other_tenant", as_app(TA, blk("b-rls", TB, SP_B1, "10:00", "11:00")))
    add("rls_orders_app_insert_other_tenant", as_app(TA, order("o-rls", TB, SITE_B1, SP_B1 + "", "CLN_DONE")))
    add("blocks_app_insert_own_tenant", as_app(TA, blk("b-app", TA, SP_A2, "10:00", "11:00")))
    add("orders_app_insert_own_tenant", as_app(TA, order("o-app", TA, SITE_A1, SP_A2)))

    # --- bloqueos
    add("block_overlap_rejected", blk("b-ov", TA, SP_A1, "10:30", "12:00"))
    add("block_open_ended_overlaps_later_ones", blk("b-open", TA, SP_A1, "09:00"))
    add("block_adjacent_ok", blk("b-adj", TA, SP_A1, "11:00", "12:00"))
    add("block_before_adjacent_ok", blk("b-adj2", TA, SP_A1, "09:00", "10:00"))
    add("block_other_space_ok", blk("b-oth", TA, SP_A2, "10:00", "11:00"))
    add("block_cancelled_does_not_conflict", blk("b-can", TA, SP_A1, "10:30", "12:00", cancelled=True))
    add("block_second_open_rejected", blk("b-o1", TA, SP_A2, "08:00") + "\n" + blk("b-o2", TA, SP_A2, "12:00"))
    add("block_maintenance_without_eta_rejected", blk("b-m1", TA, SP_A2, "13:00", "14:00", kind="BLOCK_MAINTENANCE"))
    add("block_maintenance_with_eta_ok", blk("b-m2", TA, SP_A2, "13:00", kind="BLOCK_MAINTENANCE", eta="18:00"))
    add("block_clinical_without_eta_ok", blk("b-c1", TA, SP_A2, "13:00"))
    add("block_end_before_start_rejected", blk("b-e1", TA, SP_A2, "14:00", "13:00"))
    add("block_expected_end_before_start_rejected", blk("b-e2", TA, SP_A2, "14:00", eta="13:00"))
    add("block_reason_is_mandatory", blk("b-r", TA, SP_A2, "13:00", reason=False))
    add("block_cross_tenant_space_rejected", blk("b-x", TB, SP_A1, "13:00", "14:00"))
    add("block_reopening_into_a_neighbour_rejected",
        blk("b-n1", TA, SP_A2, "10:00", "11:00") + "\n" + blk("b-n2", TA, SP_A2, "11:00", "12:00") + "\n"
        + f"UPDATE practice.care_space_blocks SET ended_at = NULL WHERE id = '{u('b-n1')}';")
    add("block_cancel_frees_the_window",
        f"UPDATE practice.care_space_blocks SET cancelled_at = now() WHERE id = '{u('b-A')}';\n" + blk("b-re", TA, SP_A1, "10:15", "10:45"))

    # --- órdenes de limpieza
    add("order_second_pending_rejected", order("o-2", TA, SITE_A1, SP_A1))
    add("order_in_progress_counts_as_open", order("o-3", TA, SITE_A1, SP_A1, "CLN_IN_PROGRESS"))
    add("order_done_counts_as_open", order("o-4", TA, SITE_A1, SP_A1, "CLN_DONE"))
    add("order_after_inspected_ok",
        f"UPDATE practice.cleaning_orders SET status_concept_id = '{c('CLN_INSPECTED')}' WHERE id = '{u('o-A')}';\n" + order("o-5", TA, SITE_A1, SP_A1))
    add("order_after_failed_inspection_chains_previous",
        f"UPDATE practice.cleaning_orders SET status_concept_id = '{c('CLN_REJECTED')}' WHERE id = '{u('o-A')}';\n"
        + order("o-6", TA, SITE_A1, SP_A1, previous="o-A"))
    add("order_after_cancel_ok",
        f"UPDATE practice.cleaning_orders SET status_concept_id = '{c('CLN_CANCELLED')}' WHERE id = '{u('o-A')}';\n" + order("o-7", TA, SITE_A1, SP_A1))
    add("order_other_space_ok", order("o-8", TA, SITE_A1, SP_A2))
    add("order_inspector_same_as_finisher_rejected", order("o-9", TA, SITE_A1, SP_A2, "CLN_INSPECTED", finished_by=USER1, inspected_by=USER1))
    add("order_inspector_differs_ok", order("o-10", TA, SITE_A1, SP_A2, "CLN_INSPECTED", finished_by=USER1, inspected_by=USER2))
    add("order_inspector_with_unknown_finisher_passes_the_check", order("o-11", TA, SITE_A1, SP_A2, "CLN_INSPECTED", inspected_by=USER2))
    add("order_unit_of_another_tenant_rejected", order("o-12", TA, SITE_A1, SP_A2, unit=UNIT_B))
    add("order_previous_of_another_tenant_rejected", order("o-13", TA, SITE_A1, SP_A2, previous="o-B"))
    add("order_site_is_not_the_spaces_site_rejected", order("o-14", TA, SITE_A2, SP_A2))
    add("order_space_of_another_tenant_rejected", order("o-15", TB, SITE_B1, SP_A2))
    add("order_priority_is_mandatory", order("o-16", TA, SITE_A1, SP_A2, priority=False))
    add("order_unit_of_the_same_tenant_ok", order("o-17", TA, SITE_A1, SP_A2, unit=UNIT_A))

    # --- historias: tenant por trigger, solo inserción, cierre de valid_to una sola vez
    for table, origin_ok, origin_other in (("care_space_blocks_history", "b-A", "b-B"), ("cleaning_orders_history", "o-A", "o-B")):
        k = "hb" if table.startswith("care_space_blocks") else "ho"
        add(f"{table}_tenant_filled_by_trigger",
            hist(table, f"{k}-n", origin_ok, None) + f"\nSELECT '@@RES {table}_tenant_filled_by_trigger|' || tenant_id FROM audit.{table} WHERE history_id = '{u(f'{k}-n')}';")
        add(f"{table}_explicit_other_tenant_rejected", hist(table, f"{k}-x", origin_ok, TB))
        add(f"{table}_tenant_follows_its_origin_when_omitted",
            hist(table, f"{k}-y", origin_other, None) + f"\nSELECT '@@RES {table}_tenant_follows_its_origin_when_omitted|' || tenant_id FROM audit.{table} WHERE history_id = '{u(f'{k}-y')}';")
        add(f"{table}_delete_rejected", f"DELETE FROM audit.{table} WHERE history_id = '{u(f'{k}-A')}';")
        add(f"{table}_update_other_column_rejected", f"UPDATE audit.{table} SET revision_no = 9 WHERE history_id = '{u(f'{k}-A')}';")
        add(f"{table}_close_valid_to_once", f"UPDATE audit.{table} SET valid_to = now() WHERE history_id = '{u(f'{k}-A')}';")
        add(f"{table}_close_valid_to_twice_rejected",
            f"UPDATE audit.{table} SET valid_to = now() WHERE history_id = '{u(f'{k}-A')}';\n"
            f"UPDATE audit.{table} SET valid_to = now() + interval '1 day' WHERE history_id = '{u(f'{k}-A')}';")
        add(f"{table}_app_closes_valid_to", as_app(TA, f"UPDATE audit.{table} SET valid_to = now() WHERE history_id = '{u(f'{k}-A')}';"))
        add(f"{table}_app_cannot_touch_other_columns", as_app(TA, f"UPDATE audit.{table} SET data_snapshot = '{{\"x\":1}}' WHERE history_id = '{u(f'{k}-A')}';"))
        add(f"{table}_app_cannot_delete", as_app(TA, f"DELETE FROM audit.{table} WHERE history_id = '{u(f'{k}-A')}';"))
        add(f"{table}_app_insert_other_tenant_rls", as_app(TA, hist(table, f"{k}-z", origin_other, TB)))

    # --- care_spaces
    add("space_new_columns_have_defaults",
        f"INSERT INTO practice.care_spaces (id, practice_site_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
        f"VALUES ('{u('sp-new')}','{SITE_A1}','NEW','NEW','{c('GEN_TYPE')}','{c('GEN_STATUS')}',now(),now(),'{TA}');\n"
        f"SELECT '@@RES space_new_columns_have_defaults|' || terminal_cleaning_required || '/' || ops_version || '/' || row_version "
        f"FROM practice.care_spaces WHERE id = '{u('sp-new')}';")
    add("space_hygiene_concept_must_exist", f"UPDATE practice.care_spaces SET hygiene_status_concept_id = '{u('no-existe')}' WHERE id = '{SP_A1}';")
    add("space_isolation_concept_must_exist", f"UPDATE practice.care_spaces SET isolation_concept_id = '{u('no-existe')}' WHERE id = '{SP_A1}';")
    add("space_availability_reason_concept_must_exist", f"UPDATE practice.care_spaces SET availability_reason_concept_id = '{u('no-existe')}' WHERE id = '{SP_A1}';")
    add("space_ops_version_not_null", f"UPDATE practice.care_spaces SET ops_version = NULL WHERE id = '{SP_A1}';")
    add("space_terminal_flag_not_null", f"UPDATE practice.care_spaces SET terminal_cleaning_required = NULL WHERE id = '{SP_A1}';")
    add("space_ops_columns_roundtrip",
        f"UPDATE practice.care_spaces SET hygiene_status_concept_id = '{c('CLEAN_ROUTINE')}', hygiene_changed_at = now(), "
        f"isolation_concept_id = '{c('CLEAN_TERMINAL')}', isolation_organism_text = 'SARM', terminal_cleaning_required = true, "
        f"availability_reason_concept_id = '{c('BLOCK_RSN_STAFF_SHORTAGE')}', availability_expected_until = now(), ops_version = 2 "
        f"WHERE id = '{SP_A1}';")
    return P


def _behavior_setup() -> str:
    seed = "\n".join([
        ev("e-A", TA, SITE_A1, SP_A1), ev("e-B", TB, SITE_B1, SP_B1),
        blk("b-A", TA, SP_A1, "10:00", "11:00"), blk("b-B", TB, SP_B1, "10:00", "11:00"),
        order("o-A", TA, SITE_A1, SP_A1), order("o-B", TB, SITE_B1, SP_B1),
        hist("care_space_blocks_history", "hb-A", "b-A", TA), hist("care_space_blocks_history", "hb-B", "b-B", TB),
        hist("cleaning_orders_history", "ho-A", "o-A", TA), hist("cleaning_orders_history", "ho-B", "o-B", TB),
    ])
    return (fixtures(concepts=ALWAYS_CONCEPTS + BACKFILL_CONCEPTS) + RESET + patch_body()
            + "\nSELECT set_config('app.system_context', '', true);\n" + seed)


@pytest.fixture(scope="module")
def behavior() -> dict[str, Probe]:
    return run_script(_behavior_setup(), _behavior_probes())


@needs_pg
class TestEventsAreAppendOnly:
    def test_valid_event_is_accepted(self, behavior):
        ok(behavior["event_valid_insert"])

    def test_the_seven_v2_0116_summaries_are_accepted(self, behavior):
        # C, H, I, K, O, U y R (extensión local) se insertan en un solo caso
        ok(behavior["event_all_v2_codes"])

    def test_unknown_v2_code_is_rejected(self, behavior):
        rejected(behavior["event_v2_invalid"], "23514", "ck_care_space_status_events_v2_code")

    def test_update_is_rejected_even_for_the_owner(self, behavior):
        rejected(behavior["event_update_rejected"], "23001", "append-only")

    def test_delete_is_rejected_even_for_the_owner(self, behavior):
        rejected(behavior["event_delete_rejected"], "23001", "append-only")

    def test_app_role_has_no_update_or_delete_privilege(self, behavior):
        rejected(behavior["event_app_cannot_update"], "42501", "permission denied")
        rejected(behavior["event_app_cannot_delete"], "42501", "permission denied")

    def test_to_concept_is_mandatory(self, behavior):
        rejected(behavior["event_missing_target_concept"], "23502", "to_concept_id")


@needs_pg
class TestTenantIsolationByReference:
    def test_event_cannot_point_to_a_space_of_another_tenant(self, behavior):
        rejected(behavior["event_cross_tenant_space"], "23503")

    def test_event_cannot_point_to_a_site_of_another_tenant(self, behavior):
        rejected(behavior["event_cross_tenant_site"], "23503")

    def test_event_site_must_be_the_spaces_site(self, behavior):
        rejected(behavior["event_site_is_not_the_spaces_site"], "23503", "fk_care_space_status_events_site_space")

    def test_block_cannot_point_to_a_space_of_another_tenant(self, behavior):
        rejected(behavior["block_cross_tenant_space_rejected"], "23503", "fk_care_space_blocks_tenant_space")

    def test_order_cannot_use_a_unit_of_another_tenant(self, behavior):
        rejected(behavior["order_unit_of_another_tenant_rejected"], "23503", "fk_cleaning_orders_tenant_unit")

    def test_order_cannot_chain_to_a_previous_order_of_another_tenant(self, behavior):
        rejected(behavior["order_previous_of_another_tenant_rejected"], "23503", "fk_cleaning_orders_tenant_previous")

    def test_order_cannot_point_to_a_space_of_another_tenant(self, behavior):
        rejected(behavior["order_space_of_another_tenant_rejected"], "23503")

    def test_order_site_must_be_the_spaces_site(self, behavior):
        rejected(behavior["order_site_is_not_the_spaces_site_rejected"], "23503", "fk_cleaning_orders_site_space")

    def test_order_unit_of_the_same_tenant_is_accepted(self, behavior):
        ok(behavior["order_unit_of_the_same_tenant_ok"])

    @pytest.mark.parametrize("table", ["care_space_blocks_history", "cleaning_orders_history"])
    def test_history_cannot_declare_a_tenant_different_from_its_origin(self, behavior, table):
        rejected(behavior[f"{table}_explicit_other_tenant_rejected"], "23503", "tenant_source")

    @pytest.mark.parametrize("table", ["care_space_blocks_history", "cleaning_orders_history"])
    def test_history_without_tenant_takes_the_origins(self, behavior, table):
        # el origen es del tenant B: la fila de historia nace en B, nunca en el tenant del que escribe
        assert behavior[f"{table}_tenant_follows_its_origin_when_omitted"].results == [TB]


@needs_pg
class TestRowLevelSecurity:
    @pytest.mark.parametrize("table", ["care_space_status_events", "care_space_blocks", "cleaning_orders",
                                       "care_space_blocks_history", "cleaning_orders_history"])
    def test_each_tenant_sees_only_its_own_rows(self, behavior, table):
        for who in ("A", "B"):
            (res,) = behavior[f"rls_{table}_{who}_sees_only_own"].results
            own, foreign = (int(x) for x in res.split("/"))
            assert own >= 1 and foreign == 0, (who, res)

    @pytest.mark.parametrize("table", ["care_space_status_events", "care_space_blocks", "cleaning_orders",
                                       "care_space_blocks_history", "cleaning_orders_history"])
    def test_without_tenant_context_nothing_is_visible(self, behavior, table):
        assert behavior[f"rls_{table}_no_context_sees_nothing"].results == ["0"]

    def test_a_tenant_cannot_update_or_delete_foreign_rows(self, behavior):
        assert behavior["rls_blocks_cannot_update_other_tenant"].results == ["0"]
        assert behavior["rls_orders_cannot_delete_other_tenant"].results == ["0"]

    def test_a_tenant_cannot_insert_rows_for_another_tenant(self, behavior):
        for name in ("event_app_insert_other_tenant_rls", "rls_blocks_app_insert_other_tenant",
                     "rls_orders_app_insert_other_tenant"):
            rejected(behavior[name], "42501", "row-level security")

    def test_a_tenant_can_insert_its_own_rows(self, behavior):
        for name in ("event_app_insert_own_tenant", "blocks_app_insert_own_tenant", "orders_app_insert_own_tenant"):
            ok(behavior[name])


@needs_pg
class TestBlocks:
    def test_overlapping_block_in_the_same_space_is_rejected(self, behavior):
        rejected(behavior["block_overlap_rejected"], "23P01", "ex_care_space_blocks_time")

    def test_an_open_block_overlaps_every_later_window(self, behavior):
        rejected(behavior["block_open_ended_overlaps_later_ones"], "23P01", "ex_care_space_blocks_time")

    def test_a_second_open_block_is_rejected(self, behavior):
        rejected(behavior["block_second_open_rejected"], "23P01", "ex_care_space_blocks_time")

    def test_adjacent_windows_are_accepted(self, behavior):
        ok(behavior["block_adjacent_ok"])
        ok(behavior["block_before_adjacent_ok"])

    def test_other_spaces_are_independent(self, behavior):
        ok(behavior["block_other_space_ok"])

    def test_a_cancelled_block_does_not_conflict(self, behavior):
        ok(behavior["block_cancelled_does_not_conflict"])
        ok(behavior["block_cancel_frees_the_window"])

    def test_reopening_a_block_into_its_neighbour_is_rejected_on_update(self, behavior):
        rejected(behavior["block_reopening_into_a_neighbour_rejected"], "23P01", "ex_care_space_blocks_time")

    def test_maintenance_requires_an_expected_end(self, behavior):
        rejected(behavior["block_maintenance_without_eta_rejected"], "23514", "ck_care_space_blocks_maintenance_eta")
        ok(behavior["block_maintenance_with_eta_ok"])

    def test_other_kinds_do_not_require_an_expected_end(self, behavior):
        ok(behavior["block_clinical_without_eta_ok"])

    def test_end_and_expected_end_cannot_precede_the_start(self, behavior):
        rejected(behavior["block_end_before_start_rejected"], "23514", "ck_care_space_blocks_end_after_start")
        rejected(behavior["block_expected_end_before_start_rejected"], "23514", "ck_care_space_blocks_end_after_start")

    def test_the_reason_is_mandatory(self, behavior):
        rejected(behavior["block_reason_is_mandatory"], "23502", "reason_concept_id")


@needs_pg
class TestCleaningOrders:
    def test_a_second_open_order_per_space_is_rejected(self, behavior):
        rejected(behavior["order_second_pending_rejected"], "23505", "ux_cleaning_orders_one_open_per_space")

    @pytest.mark.parametrize("probe", ["order_in_progress_counts_as_open", "order_done_counts_as_open"])
    def test_in_progress_and_done_also_count_as_open(self, behavior, probe):
        rejected(behavior[probe], "23505", "ux_cleaning_orders_one_open_per_space")

    @pytest.mark.parametrize("probe", ["order_after_inspected_ok", "order_after_failed_inspection_chains_previous",
                                       "order_after_cancel_ok", "order_other_space_ok"])
    def test_a_new_order_is_possible_once_the_previous_one_is_closed(self, behavior, probe):
        ok(behavior[probe])

    def test_the_inspector_cannot_be_the_one_who_finished(self, behavior):
        rejected(behavior["order_inspector_same_as_finisher_rejected"], "23514", "ck_cleaning_orders_inspector_differs")
        ok(behavior["order_inspector_differs_ok"])

    def test_an_unknown_finisher_passes_the_check(self, behavior):
        # `<>` con NULL es NULL: el CHECK del contrato no rechaza. La API es quien exige quién terminó.
        ok(behavior["order_inspector_with_unknown_finisher_passes_the_check"])

    def test_priority_is_mandatory(self, behavior):
        rejected(behavior["order_priority_is_mandatory"], "23502", "priority_concept_id")


@needs_pg
class TestStructureHistory:
    @pytest.mark.parametrize("table", ["care_space_blocks_history", "cleaning_orders_history"])
    def test_tenant_is_filled_from_the_origin(self, behavior, table):
        expected = TA
        assert behavior[f"{table}_tenant_filled_by_trigger"].results == [expected]

    @pytest.mark.parametrize("table", ["care_space_blocks_history", "cleaning_orders_history"])
    def test_only_valid_to_can_be_closed_and_only_once(self, behavior, table):
        rejected(behavior[f"{table}_delete_rejected"], "23001")
        rejected(behavior[f"{table}_update_other_column_rejected"], "23001")
        ok(behavior[f"{table}_close_valid_to_once"])
        rejected(behavior[f"{table}_close_valid_to_twice_rejected"], "23001")

    @pytest.mark.parametrize("table", ["care_space_blocks_history", "cleaning_orders_history"])
    def test_app_role_only_closes_valid_to(self, behavior, table):
        ok(behavior[f"{table}_app_closes_valid_to"])
        rejected(behavior[f"{table}_app_cannot_touch_other_columns"], "42501", "permission denied")
        rejected(behavior[f"{table}_app_cannot_delete"], "42501", "permission denied")
        rejected(behavior[f"{table}_app_insert_other_tenant_rls"], "42501", "row-level security")


@needs_pg
class TestCareSpaceColumns:
    def test_new_columns_are_there_with_their_defaults(self, behavior):
        assert behavior["space_new_columns_have_defaults"].results == ["false/1/1"]

    @pytest.mark.parametrize("probe", ["space_hygiene_concept_must_exist", "space_isolation_concept_must_exist",
                                       "space_availability_reason_concept_must_exist"])
    def test_concept_columns_are_foreign_keys(self, behavior, probe):
        rejected(behavior[probe], "23503")

    def test_counters_and_flags_are_not_null(self, behavior):
        rejected(behavior["space_ops_version_not_null"], "23502", "ops_version")
        rejected(behavior["space_terminal_flag_not_null"], "23502", "terminal_cleaning_required")

    def test_ops_columns_can_be_written(self, behavior):
        # hygiene/isolation apuntan a conceptos existentes en este escenario
        ok(behavior["space_ops_columns_roundtrip"])


# ═════════════════════════════════════ escenario B · idempotencia y backfill de los ejes
# ciclo de vida de los 4 espacios de la fixture y la higiene que el backfill debe darles
LIFECYCLE_OF = {SP_A1: "SPACE_ACTIVE", SP_A2: "SPACE_PLANNED", SP_A3: "SPACE_ACTIVE", SP_B1: "SPACE_SUSPENDED"}
STATUS_UPDATES = "".join(
    f"UPDATE practice.care_spaces SET status_concept_id = '{c(life)}' WHERE id = '{sid}';\n"
    for sid, life in LIFECYCLE_OF.items())
# A3 ya estaba OPERADO (higiene escrita por la API): el backfill no la pisa
HYGIENE_AFTER_FIRST_PASS = "UPDATE practice.care_spaces SET hygiene_status_concept_id = '" + cid("HYG_DIRTY") + f"' WHERE id = '{SP_A3}';\n"
HYG_BY_CODE = "A1:HYG_INSPECTED,A2:HYG_CLEAN,A3:HYG_DIRTY,B1:HYG_CLEAN"
HYG_REPORT_SQL = (
    "SELECT '@@RES {name}|' || string_agg(s.code || ':' || coalesce(k.code, 'NULL'), ',' ORDER BY s.code) "
    "FROM practice.care_spaces s LEFT JOIN terminology.catalog_concepts k ON k.id = s.hygiene_status_concept_id;"
)


def _lifecycle(patch_text: str | None = None) -> dict[str, Probe]:
    """Espacios previos al patch (ejes NULL) → 1.ª pasada sin los conceptos → se siembran
    SPACE_OP_AVAILABLE / HYG_CLEAN / HYG_INSPECTED / ISO_NONE → 2.ª y 3.ª pasada. Todo en UN caso
    porque el SAVEPOINT de run_script revierte cada caso."""
    closed = c("SPACE_OP_CLOSED")
    pb = lambda: patch_body(patch_text)
    setup = (
        fixtures(concepts=ALWAYS_CONCEPTS)
        + RESET
        + STATUS_UPDATES
        # un espacio ya «cerrado» a propósito: el backfill NO debe pisarlo
        + f"UPDATE practice.care_spaces SET operational_status_concept_id = '{closed}' WHERE id = '{SP_A3}';\n"
        + "SELECT '@@RES before|' || sum(row_version) || '/' || max(updated_at)::text FROM practice.care_spaces;\n"
    )

    def snapshot(name: str) -> str:
        # sin_estado/sin_higiene/sin_aislamiento/cerrados/min(ops_version)/algún terminal/Σ row_version/max updated_at
        return (
            f"SELECT '@@RES {name}|' || count(*) FILTER (WHERE operational_status_concept_id IS NULL) || '/'"
            f" || count(*) FILTER (WHERE hygiene_status_concept_id IS NULL) || '/'"
            f" || count(*) FILTER (WHERE isolation_concept_id IS NULL) || '/'"
            f" || count(*) FILTER (WHERE operational_status_concept_id = '{closed}') || '/'"
            f" || min(ops_version) || '/' || bool_or(terminal_cleaning_required)::text || '/'"
            f" || sum(row_version) || '/' || max(updated_at)::text FROM practice.care_spaces;"
        )

    sequence = (
        pb() + "\n" + snapshot("snap1") + "\n" + FINGERPRINT.format(name="fp1") + "\n"
        + HYGIENE_AFTER_FIRST_PASS
        + "SET LOCAL session_replication_role = replica;\n" + concept_rows(BACKFILL_CONCEPTS)
        + "SET LOCAL session_replication_role = origin;\n"
        + pb() + "\n" + snapshot("snap2") + "\n" + FINGERPRINT.format(name="fp2") + "\n"
        + HYG_REPORT_SQL.format(name="hyg2") + "\n"
        + pb() + "\n" + snapshot("snap3") + "\n" + FINGERPRINT.format(name="fp3") + "\n"
        + HYG_REPORT_SQL.format(name="hyg3")
        # una base armada con el DDL generado trae ops_version SIN default: el patch lo repone
        + "\nALTER TABLE practice.care_spaces ALTER COLUMN ops_version DROP DEFAULT;"
        + "\nALTER TABLE practice.care_spaces ALTER COLUMN terminal_cleaning_required DROP DEFAULT;\n"
        + pb() + "\n" + FINGERPRINT.format(name="fp4")
        + "\nWITH r AS (INSERT INTO practice.care_spaces (id, practice_site_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
          f"VALUES ('{u('sp-def')}','{SITE_A1}','DEF','DEF','{c('GEN_TYPE')}','{c('GEN_STATUS')}',now(),now(),'{TA}') "
          "RETURNING ops_version, terminal_cleaning_required) "
          "SELECT '@@RES defaults|' || ops_version || '/' || terminal_cleaning_required FROM r;"
    )
    return run_script(setup, [("sequence", sequence)])


@pytest.fixture(scope="module")
def lifecycle() -> dict[str, Probe]:
    return _lifecycle()


@needs_pg
class TestIdempotenceAndBackfill:
    def test_the_sequence_ran_without_errors(self, lifecycle):
        ok(lifecycle["sequence"])
        # tres NOTICE finales «F2 practice aplicado» (uno por pasada) los emite el patch; si
        # alguna verificación fallara habría un ERROR antes.
        assert {"snap1", "snap2", "snap3", "fp1", "fp2", "fp3", "before"} <= set(lifecycle)

    def test_second_and_third_passes_leave_the_catalog_unchanged(self, lifecycle):
        fp = [lifecycle[k].results[0] for k in ("fp1", "fp2", "fp3")]
        assert fp[0] == fp[1] == fp[2], fp
        assert int(fp[0].split("|")[1]) > 300  # no es una huella vacía

    def test_without_the_concepts_the_axes_stay_null_and_defaults_apply(self, lifecycle):
        no_status, no_hyg, no_iso, closed, ops_min, terminal, *_ = lifecycle["snap1"].results[0].split("/")
        # 4 espacios: uno ya tenía estado propio (cerrado); los demás ejes, todos NULL
        assert (no_status, no_hyg, no_iso) == ("3", "4", "4")
        assert closed == "1" and ops_min == "1" and terminal == "false"

    def test_reapplying_after_the_seed_completes_the_backfill_without_overwriting(self, lifecycle):
        for snap in ("snap2", "snap3"):
            no_status, no_hyg, no_iso, closed, *_ = lifecycle[snap].results[0].split("/")
            assert (no_status, no_hyg, no_iso) == ("0", "0", "0"), snap
            assert closed == "1", "el backfill no debe pisar un estado ya escrito"

    def test_a_missing_default_is_restored(self, lifecycle):
        assert lifecycle["fp4"].results[0] == lifecycle["fp1"].results[0]
        assert lifecycle["defaults"].results == ["1/false"]

    def test_backfill_does_not_touch_row_version_or_updated_at(self, lifecycle):
        before = lifecycle["before"].results[0]
        for snap in ("snap1", "snap2", "snap3"):
            assert lifecycle[snap].results[0].split("/", 6)[6] == before, snap


# ═════════════ escenario B2 · backfill de higiene según el ciclo de vida (HYG_INSPECTED / HYG_CLEAN)
def _hygiene_order(patch_text: str | None = None) -> dict[str, Probe]:
    """Se siembra HYG_CLEAN ANTES que HYG_INSPECTED: el espacio ACTIVE debe esperar (NULL) y no
    quedar con HYG_CLEAN; al sembrar HYG_INSPECTED y reaplicar, lo recibe sin tocar al resto."""
    pb = lambda: patch_body(patch_text)
    early = ["SPACE_OP_AVAILABLE", "HYG_CLEAN", "ISO_NONE"]
    setup = fixtures(concepts=ALWAYS_CONCEPTS) + RESET + STATUS_UPDATES
    sequence = (
        pb() + "\n" + HYGIENE_AFTER_FIRST_PASS
        + "SET LOCAL session_replication_role = replica;\n" + concept_rows(early) + "SET LOCAL session_replication_role = origin;\n"
        + pb() + "\n" + HYG_REPORT_SQL.format(name="early") + "\n" + FINGERPRINT.format(name="fp_early") + "\n"
        + "SET LOCAL session_replication_role = replica;\n" + concept_rows(["HYG_INSPECTED"]) + "SET LOCAL session_replication_role = origin;\n"
        + pb() + "\n" + HYG_REPORT_SQL.format(name="late") + "\n" + FINGERPRINT.format(name="fp_late") + "\n"
        + pb() + "\n" + HYG_REPORT_SQL.format(name="again") + "\n" + FINGERPRINT.format(name="fp_again")
    )
    return run_script(setup, [("sequence", sequence)])


@pytest.fixture(scope="module")
def hygiene_order() -> dict[str, Probe]:
    return _hygiene_order()


def hygiene_problems(lifecycle: dict[str, Probe], order: dict[str, Probe]) -> list[str]:
    """Qué incumple el backfill de higiene; vacío = correcto. La comparten la prueba y su mutación."""
    problems = []
    for k in ("hyg2", "hyg3"):
        if lifecycle[k].results[0] != HYG_BY_CODE:
            problems.append(f"{k}={lifecycle[k].results[0]}")
    if order["early"].results[0] != "A1:NULL,A2:HYG_CLEAN,A3:HYG_DIRTY,B1:HYG_CLEAN":
        problems.append(f"early={order['early'].results[0]}")
    for k in ("late", "again"):
        if order[k].results[0] != HYG_BY_CODE:
            problems.append(f"{k}={order[k].results[0]}")
    return problems


@needs_pg
class TestHygieneBackfillByLifecycle:
    def test_active_space_without_hygiene_becomes_inspected(self, lifecycle):
        assert "A1:HYG_INSPECTED" in lifecycle["hyg2"].results[0].split(",")

    def test_planned_and_suspended_spaces_become_clean(self, lifecycle):
        got = lifecycle["hyg2"].results[0].split(",")
        assert "A2:HYG_CLEAN" in got and "B1:HYG_CLEAN" in got

    def test_an_already_operated_space_is_left_alone(self, lifecycle):
        # A3 es ACTIVE y traía HYG_DIRTY escrita por la API: ni INSPECTED ni CLEAN
        assert "A3:HYG_DIRTY" in lifecycle["hyg2"].results[0].split(",")
        assert lifecycle["hyg2"].results[0] == lifecycle["hyg3"].results[0]

    def test_inspected_missing_keeps_active_spaces_waiting_then_completes(self, hygiene_order):
        ok(hygiene_order["sequence"])
        assert hygiene_order["early"].results[0] == "A1:NULL,A2:HYG_CLEAN,A3:HYG_DIRTY,B1:HYG_CLEAN"
        assert hygiene_order["late"].results[0] == HYG_BY_CODE

    def test_applying_twice_gives_the_same_catalog(self, hygiene_order):
        fp = [hygiene_order[k].results[0] for k in ("fp_early", "fp_late", "fp_again")]
        assert fp[0] == fp[1] == fp[2], fp
        assert hygiene_order["late"].results[0] == hygiene_order["again"].results[0]

    def test_no_problem_with_the_real_patch(self, lifecycle, hygiene_order):
        assert hygiene_problems(lifecycle, hygiene_order) == []

    @pytest.mark.parametrize("mutation", ["old_behaviour_clean_for_all", "inspected_without_lifecycle_filter",
                                          "clean_also_for_active", "overwrites_operated_hygiene"])
    def test_mutations_are_detected(self, mutation):
        text = PATCH.read_text(encoding="utf-8")
        inspected = "'29482974-499d-5b09-92a8-95fcfa0e521e'"
        active = "'9c27f70c-9472-5bee-92e7-78e209d581c7'"
        if mutation == "old_behaviour_clean_for_all":       # el backfill de antes: HYG_CLEAN a todos
            text = text.replace(inspected, "'7874b037-177f-5cac-adad-e7ba679d9ad3'")
        elif mutation == "inspected_without_lifecycle_filter":   # INSPECTED también a los no ACTIVE
            text = text.replace(f' AND "status_concept_id" = {active}\n', "\n", 1)
        elif mutation == "clean_also_for_active":           # el segundo UPDATE ya no excluye ACTIVE
            text = text.replace(f' AND "status_concept_id" IS DISTINCT FROM {active}\n', "\n", 1)
        else:                                               # pisa la higiene ya escrita
            text = text.replace('WHERE "hygiene_status_concept_id" IS NULL\n   AND "status_concept_id" = ' + active,
                                'WHERE true\n   AND "status_concept_id" = ' + active, 1)
        assert text != PATCH.read_text(encoding="utf-8"), "la mutación no se aplicó"
        assert hygiene_problems(_lifecycle(text), _hygiene_order(text)), f"la mutación {mutation} pasó inadvertida"


# ═══════════════════════════════════════ escenario C · precondiciones que abortan
BARE_TABLES = re.compile(r'CREATE TABLE IF NOT EXISTS "[a-z_]+"\."[a-z_]+" \(.*?\n\);', re.S)


def _bare_tables() -> str:
    stmts = BARE_TABLES.findall(PATCH.read_text(encoding="utf-8"))
    assert len(stmts) == 5
    return "\n".join(stmts)


ABORT_CASES = {
    # nombre: (filas que violan, fragmento que debe nombrar el aborto)
    "overlapping_blocks": (
        f"INSERT INTO practice.care_space_blocks (id, tenant_id, care_space_id, kind_concept_id, reason_concept_id, starts_at, ended_at, created_at, updated_at, row_version) "
        f"VALUES ('{u('x1')}','{TA}','{SP_A1}','{c('BLOCK_CLINICAL')}','{c('BLOCK_RSN_STAFF_SHORTAGE')}',{t('10:00')},{t('12:00')},now(),now(),1),"
        f"('{u('x2')}','{TA}','{SP_A1}','{c('BLOCK_CLINICAL')}','{c('BLOCK_RSN_STAFF_SHORTAGE')}',{t('11:00')},NULL,now(),now(),1);",
        "bloqueos solapados=1"),
    "maintenance_without_eta": (
        f"INSERT INTO practice.care_space_blocks (id, tenant_id, care_space_id, kind_concept_id, reason_concept_id, starts_at, created_at, updated_at, row_version) "
        f"VALUES ('{u('x1')}','{TA}','{SP_A1}','{c('BLOCK_MAINTENANCE')}','{c('BLOCK_RSN_STAFF_SHORTAGE')}',{t('10:00')},now(),now(),1);",
        "mantenimiento sin fecha estimada=1"),
    "end_before_start": (
        f"INSERT INTO practice.care_space_blocks (id, tenant_id, care_space_id, kind_concept_id, reason_concept_id, starts_at, ended_at, created_at, updated_at, row_version) "
        f"VALUES ('{u('x1')}','{TA}','{SP_A1}','{c('BLOCK_CLINICAL')}','{c('BLOCK_RSN_STAFF_SHORTAGE')}',{t('12:00')},{t('10:00')},now(),now(),1);",
        "fin anterior al inicio=1"),
    "invalid_v2_code": (
        f"INSERT INTO practice.care_space_status_events (id, tenant_id, practice_site_id, care_space_id, axis_concept_id, to_concept_id, v2_0116_code, source_concept_id, occurred_at, created_at) "
        f"VALUES ('{u('x1')}','{TA}','{SITE_A1}','{SP_A1}','{c('AXIS_AVAILABILITY')}','{c('SPACE_OP_BLOCKED_CLINICAL')}','Z','{c('SRC_MANUAL')}',now(),now());",
        "código v2-0116 inválido=1"),
    "two_open_orders_in_one_space": (
        "".join(
            f"INSERT INTO practice.cleaning_orders (id, tenant_id, practice_site_id, care_space_id, cleaning_type_concept_id, trigger_concept_id, priority_concept_id, status_concept_id, requested_at, created_at, updated_at, row_version) "
            f"VALUES ('{u(i)}','{TA}','{SITE_A1}','{SP_A1}','{c('CLEAN_ROUTINE')}','{c('CLN_TRG_MANUAL')}','{c('CLN_PRIO_ROUTINE')}','{c(s)}',now(),now(),now(),1);"
            for i, s in (("x1", "CLN_PENDING"), ("x2", "CLN_DONE"))),
        "más de una orden de limpieza abierta=1"),
    "inspector_is_the_finisher": (
        f"INSERT INTO practice.cleaning_orders (id, tenant_id, practice_site_id, care_space_id, cleaning_type_concept_id, trigger_concept_id, priority_concept_id, status_concept_id, requested_at, finished_by_user_id, inspected_by_user_id, created_at, updated_at, row_version) "
        f"VALUES ('{u('x1')}','{TA}','{SITE_A1}','{SP_A1}','{c('CLEAN_ROUTINE')}','{c('CLN_TRG_MANUAL')}','{c('CLN_PRIO_ROUTINE')}','{c('CLN_INSPECTED')}',now(),'{USER1}','{USER1}',now(),now(),1);",
        "inspector = quien terminó=1"),
    "event_of_another_tenant": (
        f"INSERT INTO practice.care_space_status_events (id, tenant_id, practice_site_id, care_space_id, axis_concept_id, to_concept_id, v2_0116_code, source_concept_id, occurred_at, created_at) "
        f"VALUES ('{u('x1')}','{TB}','{SITE_A1}','{SP_A1}','{c('AXIS_AVAILABILITY')}','{c('SPACE_OP_BLOCKED_CLINICAL')}','C','{c('SRC_MANUAL')}',now(),now());",
        "care_space_status_events.practice_site_id"),
    "order_with_a_site_that_is_not_the_spaces": (
        f"INSERT INTO practice.cleaning_orders (id, tenant_id, practice_site_id, care_space_id, cleaning_type_concept_id, trigger_concept_id, priority_concept_id, status_concept_id, requested_at, created_at, updated_at, row_version) "
        f"VALUES ('{u('x1')}','{TA}','{SITE_A2}','{SP_A1}','{c('CLEAN_ROUTINE')}','{c('CLN_TRG_MANUAL')}','{c('CLN_PRIO_ROUTINE')}','{c('CLN_PENDING')}',now(),now(),now(),1);",
        "cleaning_orders.sede≠sede del espacio"),
    "block_of_another_tenant": (
        f"INSERT INTO practice.care_space_blocks (id, tenant_id, care_space_id, kind_concept_id, reason_concept_id, starts_at, ended_at, created_at, updated_at, row_version) "
        f"VALUES ('{u('x1')}','{TB}','{SP_A1}','{c('BLOCK_CLINICAL')}','{c('BLOCK_RSN_STAFF_SHORTAGE')}',{t('10:00')},{t('11:00')},now(),now(),1);",
        "care_space_blocks.care_space_id"),
}


def _abort_run() -> dict[str, Probe]:
    setup = fixtures(concepts=ALWAYS_CONCEPTS + BACKFILL_CONCEPTS) + RESET + _bare_tables()
    probes = []
    for name, (rows, _fragment) in ABORT_CASES.items():
        # Con RLS forzada y superusuario no hay filtro; las filas se siembran con las FK sueltas
        # (las tablas «desnudas» todavía no las tienen) y se aplica el patch dentro del caso.
        probes.append((name, rows + "\nSAVEPOINT patch_sp;\n" + patch_body()
                       + "\nROLLBACK TO SAVEPOINT patch_sp;\n"
                       + f"SELECT '@@RES {name}|' || count(*) FROM information_schema.columns "
                         "WHERE table_schema = 'practice' AND table_name = 'care_spaces' AND column_name IN ('ops_version', 'hygiene_status_concept_id');"))
    return run_script(setup, probes)


@pytest.fixture(scope="module")
def aborts() -> dict[str, Probe]:
    return _abort_run()


@needs_pg
class TestIncompatibleDataAborts:
    @pytest.mark.parametrize("case", list(ABORT_CASES))
    def test_the_patch_stops_and_names_the_offending_rows(self, aborts, case):
        probe = aborts[case]
        fragment = ABORT_CASES[case][1]
        assert probe.code in ("23514", "23503"), (probe.code, probe.message)
        assert fragment in probe.message, probe.message

    @pytest.mark.parametrize("case", list(ABORT_CASES))
    def test_nothing_is_left_applied(self, aborts, case):
        # tras el aborto (rollback del SAVEPOINT) care_spaces no tiene ninguna columna nueva
        assert aborts[case].results == ["0"]

    def test_pre_existing_tables_without_constraints_are_adopted_when_data_is_clean(self):
        setup = fixtures(concepts=ALWAYS_CONCEPTS + BACKFILL_CONCEPTS) + RESET + _bare_tables()
        direct = fixtures(concepts=ALWAYS_CONCEPTS + BACKFILL_CONCEPTS) + RESET
        adopted = run_script(setup, [("go", patch_body() + "\n" + FINGERPRINT.format(name="fp_adopted"))])
        created = run_script(direct, [("go", patch_body() + "\n" + FINGERPRINT.format(name="fp_created"))])
        ok(adopted["go"])
        ok(created["go"])
        assert adopted["fp_adopted"].results[0] == created["fp_created"].results[0], (
            "el catálogo resultante debe ser idéntico tanto si las tablas las crea el patch como si ya existían")
