"""Soporte de las pruebas de F4 contra un Postgres real (sin dependencias de terceros: psql).

Las pruebas con base NO se ejecutan si falta SALUD_TEST_PGDATABASE: apuntan a una copia
descartable del modelo con F1 + F1b (+ F5) aplicados, p. ej. `CREATE DATABASE m_f4 TEMPLATE alovida`.

    SALUD_TEST_PGDATABASE=m_f4 PGPASSWORD=… python -m pytest salud-db/tests/test_infra_f4_db.py

Variables: SALUD_TEST_PGHOST (localhost), SALUD_TEST_PGPORT (5433), SALUD_TEST_PGUSER (mantra),
PGPASSWORD (la de tu base local) y SALUD_TEST_PGDATABASE (obligatoria).

Nada de lo que corren estas pruebas se confirma: cada escenario es UN psql con
`BEGIN; … ROLLBACK;`, incluidos los dos pasos del patch, así que la base queda como estaba.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path

MODEL_ROOT = Path(__file__).resolve().parents[2]
PATCHES = MODEL_ROOT / "SQL" / "patches"
PATCH_SCHEDULING = PATCHES / "2026-10-29_infraestructura_f4_scheduling.sql"
PATCH_PERIOP = PATCHES / "2026-10-29_infraestructura_f4_periop.sql"

# --- UUID de conceptos (deterministicId de la API; verificados contra el algoritmo en
# test_infra_f4_contracts.py) -------------------------------------------------------------------
STATE_ACTIVE = "38a1d301-f40d-5b17-a695-5e6d605f8b19"
CASE_SCHEDULED = "6fe38139-ad1d-5214-84c1-8c184e4e58fb"
CASE_READY = "f6985cd5-f867-5d76-b70c-1138667fd2ab"
CASE_IN_PROGRESS = "fdc78cc9-eda6-5625-9a26-1bdcec4dc203"
CASE_CANCELLED = "225373d6-a919-5fa0-8155-35892302a7df"
RES_ROOM = "2e3d1a52-5455-5714-a4f2-db0879616235"
ORB_ACTIVE = "762dc30b-3e3c-5e1e-8504-5c511fd1d4a8"
ORB_RELEASED = "c3225706-ef13-5cbe-af6d-caaf25437458"
ORB_CANCELLED = "e420cc84-8fd2-5887-a9bd-faf77d561508"
ORB_OWNER_SERVICE = "6b4fd1e9-892f-572b-9e9b-96b321ecdc26"
ORB_OWNER_SURGEON = "48a989b7-6300-516d-9982-8f741aaf0758"
CONCEPT_OTHER = "c0c0c0c0-0000-4000-8000-000000000001"   # concepto genérico (tipo, prioridad…)
CONCEPT_SPECIALTY = "c0c0c0c0-0000-4000-8000-000000000002"
CONCEPT_CHK_ENTRY = "c0c0c0c0-0000-4000-8000-000000000003"
CONCEPT_CHK_PAUSE = "c0c0c0c0-0000-4000-8000-000000000004"
CONCEPT_EVENT = "c0c0c0c0-0000-4000-8000-000000000005"
ALL_CONCEPTS = [STATE_ACTIVE, CASE_SCHEDULED, CASE_READY, CASE_IN_PROGRESS, CASE_CANCELLED, RES_ROOM,
                ORB_ACTIVE, ORB_RELEASED, ORB_CANCELLED, ORB_OWNER_SERVICE, ORB_OWNER_SURGEON,
                CONCEPT_OTHER, CONCEPT_SPECIALTY, CONCEPT_CHK_ENTRY, CONCEPT_CHK_PAUSE, CONCEPT_EVENT]

# --- filas de la fixture -----------------------------------------------------------------------
T_A = "a0000000-0000-4000-8000-000000000001"
T_B = "b0000000-0000-4000-8000-000000000001"
PRACTICE_A = "a0000000-0000-4000-8000-0000000000f1"
PRACTICE_B = "b0000000-0000-4000-8000-0000000000f1"
SITE_A1 = "a0000000-0000-4000-8000-0000000000a1"
SITE_A2 = "a0000000-0000-4000-8000-0000000000a2"
SITE_B1 = "b0000000-0000-4000-8000-0000000000a1"
UNIT_A1 = "a0000000-0000-4000-8000-0000000000b1"
UNIT_B1 = "b0000000-0000-4000-8000-0000000000b1"
OR_A1 = "a0000000-0000-4000-8000-0000000000c1"        # prep 15 / limpieza 20
OR_A2 = "a0000000-0000-4000-8000-0000000000c2"        # sin recambio (NULL / NULL)
OR_A_SITE2 = "a0000000-0000-4000-8000-0000000000c3"   # otra sede del mismo tenant
OR_B1 = "b0000000-0000-4000-8000-0000000000c1"        # otro tenant
SURGEON = "a0000000-0000-4000-8000-0000000000d1"
PATIENT = "a0000000-0000-4000-8000-0000000000d2"
USER_1 = "a0000000-0000-4000-8000-0000000000d3"

_FX = r"""
CREATE OR REPLACE FUNCTION pg_temp.fx(rel regclass, ov jsonb DEFAULT '{}'::jsonb) RETURNS void
LANGUAGE plpgsql AS $fxfn$
DECLARE
    a record;
    j jsonb := ov;
    v jsonb;
BEGIN
    FOR a IN SELECT attname::text AS n, format_type(atttypid, atttypmod) AS t
               FROM pg_attribute
              WHERE attrelid = rel AND attnum > 0 AND NOT attisdropped AND attnotnull AND attgenerated = ''
    LOOP
        IF NOT (j ? a.n) THEN
            v := CASE
                WHEN a.t = 'uuid' THEN to_jsonb(gen_random_uuid()::text)
                WHEN a.t IN ('integer', 'smallint', 'bigint') THEN to_jsonb(1)
                WHEN a.t LIKE 'timestamp%' THEN to_jsonb(now()::text)
                WHEN a.t = 'date' THEN to_jsonb(current_date::text)
                WHEN a.t LIKE 'time%' THEN to_jsonb('00:00'::text)
                WHEN a.t = 'boolean' THEN to_jsonb(false)
                WHEN a.t = 'jsonb' THEN '{}'::jsonb
                WHEN a.t LIKE 'numeric%' THEN to_jsonb(1)
                WHEN a.t = 'smallint[]' THEN '[1]'::jsonb
                ELSE to_jsonb(md5(random()::text))
            END;
            j := j || jsonb_build_object(a.n, v);
        END IF;
    END LOOP;
    EXECUTE format('INSERT INTO %s SELECT * FROM jsonb_populate_record(NULL::%s, $1)', rel, rel) USING j;
END $fxfn$;

-- Ejecuta una sentencia en una subtransacción y devuelve «etiqueta=SQLSTATE|mensaje» (OK si no falla).
CREATE OR REPLACE FUNCTION pg_temp.try(label text, stmt text) RETURNS text
LANGUAGE plpgsql AS $tryfn$
BEGIN
    EXECUTE stmt;
    RETURN label || '=OK|';
EXCEPTION WHEN OTHERS THEN
    RETURN label || '=' || SQLSTATE || '|' || replace(SQLERRM, E'\n', ' ');
END $tryfn$;
"""


def fx(table: str, **cols) -> str:
    """SELECT que inserta una fila (rellena con valores genéricos las columnas NOT NULL que falten)."""
    return f"SELECT pg_temp.fx('{table}', $j${json.dumps(cols)}$j$::jsonb);"


def try_(label: str, stmt: str) -> str:
    """SELECT que ejecuta `stmt` en una subtransacción; su resultado sale como «label=SQLSTATE|msg»."""
    assert "$tq$" not in stmt
    return f"SELECT pg_temp.try('{label}', $tq${stmt}$tq$);"


def _insert_concepts() -> str:
    return "\n".join(fx("terminology.catalog_concepts", id=c, code="F4-" + c[:8]) for c in ALL_CONCEPTS)


# Una fila insertada en la misma transacción se re-verifica entera en cada UPDATE (aunque no toque la
# FK): los espacios de la fixture apuntan, por eso, a conceptos que existen de verdad.
_SPACE_CONCEPTS = {"space_type_concept_id": CONCEPT_OTHER, "status_concept_id": CONCEPT_OTHER}


def fixture_sql(*, scheduling_columns: bool = True) -> str:
    """Padres de las pruebas, insertados con `session_replication_role = replica` (sin FK ni triggers de
    usuario) y vuelta a `origin`: lo que las pruebas insertan DESPUÉS sí valida FK, CHECK, EXCLUDE y
    triggers, y encuentra a estos padres ya presentes."""
    rows = [
        "SET LOCAL session_replication_role = replica;",
        _insert_concepts(),
        fx("directory.tenants", id=T_A, code="f4-a"),
        fx("directory.tenants", id=T_B, code="f4-b"),
        fx("practice.practices", id=PRACTICE_A, tenant_id=T_A),
        fx("practice.practices", id=PRACTICE_B, tenant_id=T_B),
        fx("practice.practice_sites", id=SITE_A1, tenant_id=T_A, practice_id=PRACTICE_A),
        fx("practice.practice_sites", id=SITE_A2, tenant_id=T_A, practice_id=PRACTICE_A),
        fx("practice.practice_sites", id=SITE_B1, tenant_id=T_B, practice_id=PRACTICE_B),
        fx("practice.clinical_units", id=UNIT_A1, tenant_id=T_A, practice_site_id=SITE_A1),
        fx("practice.clinical_units", id=UNIT_B1, tenant_id=T_B, practice_site_id=SITE_B1),
        fx("practice.care_spaces", id=OR_A1, tenant_id=T_A, practice_site_id=SITE_A1, code="OR-A1",
           prep_minutes=15, cleanup_minutes=20, **_SPACE_CONCEPTS),
        fx("practice.care_spaces", id=OR_A2, tenant_id=T_A, practice_site_id=SITE_A1, code="OR-A2", **_SPACE_CONCEPTS),
        fx("practice.care_spaces", id=OR_A_SITE2, tenant_id=T_A, practice_site_id=SITE_A2, code="OR-A3", **_SPACE_CONCEPTS),
        fx("practice.care_spaces", id=OR_B1, tenant_id=T_B, practice_site_id=SITE_B1, code="OR-B1", **_SPACE_CONCEPTS),
        fx("profiles.health_practitioner_profiles", profile_id=SURGEON),
        fx("profiles.patient_profiles", profile_id=PATIENT),
        fx("iam.users", id=USER_1),
        "SET LOCAL session_replication_role = origin;",
    ]
    return "\n".join(rows)


def strip_tx(patch: str) -> str:
    """Quita el BEGIN; inicial y el COMMIT; final del patch para correrlo dentro de la transacción
    de la prueba (que termina siempre en ROLLBACK)."""
    out, quitados = [], 0
    for line in patch.splitlines():
        if line.strip() in ("BEGIN;", "COMMIT;"):
            quitados += 1
            continue
        out.append(line)
    assert quitados == 2, "el patch debe tener exactamente un BEGIN; y un COMMIT;"
    return "\n".join(out)


@dataclass
class Result:
    rc: int
    out: str
    err: str

    def labels(self) -> dict[str, tuple[str, str]]:
        """«etiqueta=SQLSTATE|mensaje» de cada `try_` → {etiqueta: (SQLSTATE, mensaje)}."""
        found = {}
        for m in re.finditer(r"^([A-Za-z0-9_.\-]+)=([0-9A-Z]{2,5}|OK)\|(.*)$", self.out, re.M):
            found[m.group(1)] = (m.group(2), m.group(3))
        return found

    def notices(self) -> list[str]:
        return [l.split("NOTICE:", 1)[1].strip() for l in self.err.splitlines() if "NOTICE:" in l]


def database() -> str | None:
    return os.environ.get("SALUD_TEST_PGDATABASE")


def psql(sql: str, *, timeout: int = 180) -> Result:
    env = dict(os.environ)
    cmd = ["psql", "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1",
           "-h", os.environ.get("SALUD_TEST_PGHOST", "localhost"),
           "-p", os.environ.get("SALUD_TEST_PGPORT", "5433"),
           "-U", os.environ.get("SALUD_TEST_PGUSER", "mantra"),
           "-d", database() or "", "-f", "-"]
    p = subprocess.run(cmd, input=sql, capture_output=True, text=True, env=env, timeout=timeout)
    return Result(p.returncode, p.stdout, p.stderr)


def scenario(body: str, *, fixture: bool = True, rollback: bool = True, prelude: str = "") -> Result:
    """UN psql: BEGIN; helpers; [fixture]; prelude; cuerpo; ROLLBACK."""
    parts = ["BEGIN;", "SET LOCAL app.system_context = 'true';", _FX]
    if fixture:
        parts.append(fixture_sql())
    if prelude:
        parts.append(prelude)
    parts.append(body)
    if rollback:
        parts.append("ROLLBACK;")
    return psql("\n".join(parts))


def patches_applied() -> bool:
    r = psql("SELECT to_regclass('procedures_perioperative.operating_room_blocks') IS NOT NULL "
             "AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='scheduling' "
             "AND table_name='schedulable_resources' AND column_name='care_space_id');")
    return r.rc == 0 and r.out.strip() == "t"


_F4_TABLES = ("'procedures_perioperative.procedure_cases', 'procedures_perioperative.operating_room_utilization_events', "
              "'procedures_perioperative.operating_room_block_series', 'procedures_perioperative.operating_room_blocks', "
              "'procedures_perioperative.surgical_safety_checklists', 'scheduling.schedulable_resources', "
              "'audit.operating_room_block_series_history', 'audit.operating_room_blocks_history'")

# Huella del catálogo de todo lo que tocan los dos patches de F4: una fila «categoría|cantidad|md5».
SNAPSHOT_SQL = f"""
SELECT cat || '|' || count(*) || '|' || md5(coalesce(string_agg(x, E'\\n' ORDER BY x), ''))
  FROM (
    SELECT 'columnas' AS cat, c.table_schema || '.' || c.table_name || '.' || c.column_name || ':' || c.data_type || ':' || c.is_nullable AS x
      FROM information_schema.columns c WHERE c.table_schema || '.' || c.table_name IN ({_F4_TABLES})
    UNION ALL
    SELECT 'indices', schemaname || '.' || indexname || ':' || indexdef
      FROM pg_indexes WHERE schemaname || '.' || tablename IN ({_F4_TABLES})
    UNION ALL
    SELECT 'restricciones', conrelid::regclass::text || ':' || conname || ':' || pg_get_constraintdef(oid) || ':' || convalidated
      FROM pg_constraint WHERE conrelid::regclass::text IN ({_F4_TABLES})
    UNION ALL
    SELECT 'triggers', pg_get_triggerdef(oid)
      FROM pg_trigger WHERE NOT tgisinternal AND tgrelid::regclass::text IN ({_F4_TABLES})
    UNION ALL
    SELECT 'politicas', schemaname || '.' || tablename || ':' || policyname || ':' || coalesce(qual, '') || ':' || coalesce(with_check, '')
      FROM pg_policies WHERE schemaname || '.' || tablename IN ({_F4_TABLES})
    UNION ALL
    SELECT 'privilegios', relnamespace::regnamespace || '.' || relname || ':' || coalesce(relacl::text, '') || ':' || relrowsecurity || relforcerowsecurity
      FROM pg_class WHERE relnamespace::regnamespace || '.' || relname IN ({_F4_TABLES})
    UNION ALL
    SELECT 'funciones', pg_get_functiondef(p.oid)
      FROM pg_proc p WHERE p.proname IN ('procedure_cases_set_reserved_window', 'operating_room_utilization_events_fill_tenant',
                                         'operating_room_block_series_assert_room_site', 'operating_room_blocks_assert_series_room')
  ) s GROUP BY cat ORDER BY cat;
"""


def snapshot(sql_runner=None) -> dict[str, str]:
    r = (sql_runner or psql)(SNAPSHOT_SQL)
    assert r.rc == 0, r.err
    out = {}
    for line in r.out.strip().splitlines():
        cat, n, h = line.split("|")
        out[cat] = f"{n}|{h}"
    return out
