"""F3 (internación / ADT) contra un Postgres REAL — no mocks.

Qué hace: clona una base ya construida con el modelo (F1 + F1b + F5 aplicados) y, sobre la
copia, ejercita `SQL/patches/2026-10-29_infraestructura_f3_clinical.sql`:

  A. sobre datos heredados incompatibles el patch ABORTA sin tocar nada (cama solapada, encuentro
     en dos camas, dos ACTIVE, rango invertido, cama sin inicio, ubicación de otro tenant, falta F1b);
  B. sobre datos heredados válidos aplica (backfill de tenant y de camas), y aplicado una SEGUNDA vez
     deja el catálogo idéntico (huella md5 de columnas, constraints, índices, triggers, políticas,
     privilegios y funciones);
  C. recrea diferibles los EXCLUDE si un rebuild (gen_integrity) los dejó inmediatos;
  D. comportamiento: dos pacientes no ocupan la misma cama a la vez (secuencial y con dos conexiones
     concurrentes), el traslado deja un solo registro activo y es todo-o-nada, el intercambio A17 exige
     restricciones diferidas, RLS entre tenants, FK compuestas, incidentes, censo inmutable e historias
     solo-inserción.

Las pruebas A→C son una secuencia (cada una deja la base como la necesita la siguiente): pytest las
corre en el orden del archivo. No se usa `alovida` directamente: la base de trabajo se crea con
`CREATE DATABASE <F3_TEST_DB> TEMPLATE <F3_TEMPLATE_DB>` y se borra al terminar.

Entorno (valores por defecto = el Postgres local de ENTORNO-LOCAL.md):
  F3_PG_HOST=localhost F3_PG_PORT=5433 F3_PG_USER=mantra F3_PG_PASSWORD=local_dev_only
  F3_TEMPLATE_DB=alovida   F3_TEST_DB=m_f3_pytest   F3_KEEP_DB=1 para conservar la base al final.
Sin Postgres alcanzable (o sin `psycopg`/`psql`) el módulo se OMITE con el motivo a la vista.
"""
from __future__ import annotations

import datetime as dt
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import uuid
from pathlib import Path

import pytest

psycopg = pytest.importorskip("psycopg", reason="falta psycopg (pip install -r salud-db/requirements.txt)")
from psycopg import errors as pgerr  # noqa: E402

sys.path.insert(0, str(Path(__file__).resolve().parent))
from test_infra_f3_clinical_contract import deterministic_id  # noqa: E402

REPO = Path(__file__).resolve().parents[2]
# F3_PATCH apunta a otra copia del patch (pruebas de mutación: una copia rota tiene que hacer fallar esta suite)
PATCH = Path(os.environ.get("F3_PATCH") or REPO / "SQL" / "patches" / "2026-10-29_infraestructura_f3_clinical.sql")

HOST = os.environ.get("F3_PG_HOST", "localhost")
PORT = os.environ.get("F3_PG_PORT", "5433")
USER = os.environ.get("F3_PG_USER", "mantra")
PASSWORD = os.environ.get("F3_PG_PASSWORD", "local_dev_only")
TEMPLATE_DB = os.environ.get("F3_TEMPLATE_DB", "alovida")
TEST_DB = os.environ.get("F3_TEST_DB", "m_f3_pytest")


def _dsn(db: str) -> str:
    return f"host={HOST} port={PORT} user={USER} password={PASSWORD} dbname={db}"


def _server_up() -> str | None:
    """None si todo está disponible; si no, el motivo para omitir el módulo."""
    if shutil.which("psql") is None:
        return "no hay binario psql en PATH"
    try:
        with psycopg.connect(_dsn("postgres"), connect_timeout=3) as c:
            row = c.execute("SELECT 1 FROM pg_database WHERE datname = %s", (TEMPLATE_DB,)).fetchone()
            if not row:
                return f"no existe la base plantilla {TEMPLATE_DB!r}"
    except Exception as exc:  # noqa: BLE001
        return f"Postgres no alcanzable en {HOST}:{PORT}: {exc}"
    return None


_SKIP = _server_up()
pytestmark = pytest.mark.skipif(_SKIP is not None, reason=f"F3 DB: {_SKIP}")


# ----------------------------------------------------------------------------- ids de la fixture
def uid(name: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_URL, f"mantra-f3-test:{name}"))


T1, T2 = uid("tenant-1"), uid("tenant-2")
U1 = uid("user-1")
PR1, PR2 = uid("practice-1"), uid("practice-2")
S1, S2 = uid("site-1"), uid("site-2")
UN1, UN2 = uid("unit-1"), uid("unit-2")
BED = {i: uid(f"bed-{i}") for i in range(1, 7)}        # camas del tenant 1
R1 = uid("room-1")                                      # local (no cama) del tenant 1
BX = uid("bed-x")                                       # cama del tenant 2
PAT = {i: uid(f"patient-{i}") for i in range(1, 10)}    # 1..8 tenant 1, 9 tenant 2
ENC = {i: uid(f"encounter-{i}") for i in range(1, 10)}  # 1..8 tenant 1, 9 tenant 2
CSV = uid("code-system-version")

C = {  # concepto → id. Los de ubicación son los deterministicId() reales que usa el patch.
    "ACTIVE": deterministic_id("clinical:LOCATION_ACTIVE"),
    "COMPLETED": deterministic_id("clinical:LOCATION_COMPLETED"),
    "RESERVED": deterministic_id("clinical:LOCATION_RESERVED"),
    "CANCELLED": deterministic_id("clinical:LOCATION_CANCELLED"),
    "FORM_BED": deterministic_id("practice:LOC_FORM_BED"),
    "FORM_ROOM": deterministic_id("practice:LOC_FORM_ROOM"),
}
for _k in ("ANY", "ADT_ADMIT", "ADT_TRANSFER", "ADT_SWAP", "END_TRANSFER_OUT", "BED_CAT_ICU", "PLC_INC_OPEN",
           "CENSUS_OPEN", "CENSUS_CLOSED", "CEN_PRESENT", "OP_INSERT"):
    C[_k] = deterministic_id(f"clinical:{_k}")

D0 = dt.datetime(2026, 10, 1, tzinfo=dt.timezone.utc)


def day(n: int) -> dt.datetime:
    return D0 + dt.timedelta(days=n)


# ----------------------------------------------------------------------------- helpers de base
def run_psql(db: str, *, files: list[Path] | None = None, cmds: list[str] | None = None) -> subprocess.CompletedProcess:
    args = ["psql", "-h", HOST, "-p", PORT, "-U", USER, "-d", db, "-X", "-v", "ON_ERROR_STOP=1"]
    for c in cmds or []:
        args += ["-c", c]
    for f in files or []:
        args += ["-f", str(f)]
    return subprocess.run(args, capture_output=True, text=True, env={**os.environ, "PGPASSWORD": PASSWORD})


class World:
    """La base de trabajo, su conexión de superusuario y los helpers de fixture."""

    def __init__(self, dbname: str) -> None:
        self.db = dbname
        self.conn = psycopg.connect(_dsn(dbname), autocommit=True)
        self.fp_after_first: str | None = None

    # ---- consultas
    def one(self, sql: str, params=()):
        row = self.conn.execute(sql, params).fetchone()
        return row[0] if row else None

    def all(self, sql: str, params=()):
        return self.conn.execute(sql, params).fetchall()

    def has_column(self, table: str, col: str) -> bool:
        return bool(self.one("SELECT count(*) FROM information_schema.columns WHERE table_schema = 'clinical' "
                             "AND table_name = %s AND column_name = %s", (table, col)))

    def patched(self) -> bool:
        return self.has_column("encounter_locations", "is_bed_assignment") and \
            self.one("SELECT to_regclass('clinical.inpatient_census_days')") is not None

    def apply_patch(self) -> subprocess.CompletedProcess:
        return run_psql(self.db, files=[PATCH])

    def fingerprint(self) -> str:
        sql = (Path(__file__).with_name("f3_fingerprint.sql")).read_text(encoding="utf-8")
        return "|".join(str(x) for x in self.conn.execute(sql).fetchone())

    # ---- fixture: andamio (se inserta con FK desactivadas; sólo son hojas de referencia) y datos
    def seed_scaffold(self) -> None:
        c = self.conn
        c.execute("SET session_replication_role = replica")
        try:
            for name, cid in C.items():
                c.execute("INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, created_at, updated_at) "
                          "VALUES (%s, %s, %s, %s, now(), now()) ON CONFLICT DO NOTHING", (cid, CSV, f"F3T_{name}", f"f3 test {name}"))
            c.execute("INSERT INTO iam.users (id, status_concept_id, display_name, created_at, updated_at) VALUES (%s, %s, 'f3 user', now(), now())",
                      (U1, C["ANY"]))
            for t, code in ((T1, "F3T1"), (T2, "F3T2")):
                c.execute("INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, legal_entity_type_concept_id, "
                          "status_concept_id, verification_status_concept_id, created_at, updated_at) "
                          "VALUES (%s, %s, %s, %s, %s, %s, %s, now(), now())",
                          (t, code, C["ANY"], f"Tenant {code}", C["ANY"], C["ANY"], C["ANY"]))
            for pr, t, code in ((PR1, T1, "PR1"), (PR2, T2, "PR2")):
                c.execute("INSERT INTO practice.practices (id, tenant_id, code, name, type_concept_id, admin_user_id, status_concept_id, created_at, updated_at) "
                          "VALUES (%s, %s, %s, %s, %s, %s, %s, now(), now())", (pr, t, code, code, C["ANY"], U1, C["ANY"]))
            for s, pr, t, code in ((S1, PR1, T1, "S1"), (S2, PR2, T2, "S2")):
                c.execute("INSERT INTO practice.practice_sites (id, practice_id, code, name, site_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
                          "VALUES (%s, %s, %s, %s, %s, %s, now(), now(), %s)", (s, pr, code, code, C["ANY"], C["ANY"], t))
            for un, s, t, code in ((UN1, S1, T1, "UN1"), (UN2, S2, T2, "UN2")):
                c.execute("INSERT INTO practice.clinical_units (id, practice_site_id, code, name, unit_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
                          "VALUES (%s, %s, %s, %s, %s, %s, now(), now(), %s)", (un, s, code, code, C["ANY"], C["ANY"], t))
            spaces = [(BED[i], S1, T1, UN1, f"B{i}", C["FORM_BED"]) for i in BED] + \
                     [(R1, S1, T1, UN1, "R1", C["FORM_ROOM"]), (BX, S2, T2, UN2, "BX", C["FORM_BED"])]
            for sp, s, t, un, code, form in spaces:
                c.execute("INSERT INTO practice.care_spaces (id, practice_site_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, "
                          "tenant_id, form_concept_id, clinical_unit_id, censable) VALUES (%s, %s, %s, %s, %s, %s, now(), now(), %s, %s, %s, true)",
                          (sp, s, code, code, C["ANY"], C["ANY"], t, form, un))
            for i, p in PAT.items():
                c.execute("INSERT INTO profiles.patient_profiles (profile_id, patient_code, created_at, updated_at) VALUES (%s, %s, now(), now())", (p, f"F3P{i}"))
            for i, e in ENC.items():
                c.execute("INSERT INTO clinical.encounters (id, patient_profile_id, tenant_id, status_concept_id, created_at, updated_at) "
                          "VALUES (%s, %s, %s, %s, now(), now())", (e, PAT[i], T2 if i == 9 else T1, C["ANY"]))
        finally:
            c.execute("SET session_replication_role = origin")

    def legacy_loc(self, enc: str, space: str | None, status: str, start, end=None, *, site: str = S1, loc_id: str | None = None) -> str:
        """Fila `encounter_locations` con SÓLO las columnas de antes de F3 (así escribía la API vieja)."""
        loc_id = loc_id or str(uuid.uuid4())
        self.conn.execute("INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, "
                          "period_start, period_end, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, now(), now())",
                          (loc_id, enc, site, space, C[status], start, end))
        return loc_id

    def loc(self, conn, enc: str, space: str | None, status: str, start, end=None, *, bed: bool = True, **extra) -> str:
        """Fila de F3 (con is_bed_assignment); tenant_id lo completa el trigger salvo que se pase en `extra`."""
        loc_id = extra.pop("loc_id", str(uuid.uuid4()))
        cols = {"id": loc_id, "encounter_id": enc, "practice_site_id": S1, "care_space_id": space,
                "location_status_concept_id": C[status], "period_start": start, "period_end": end,
                "is_bed_assignment": bed, "created_at": dt.datetime.now(dt.timezone.utc), "updated_at": dt.datetime.now(dt.timezone.utc)}
        cols.update(extra)
        names = ", ".join(cols)
        conn.execute(f"INSERT INTO clinical.encounter_locations ({names}) VALUES ({', '.join(['%s'] * len(cols))})", list(cols.values()))
        return loc_id

    def wipe_locations(self) -> None:
        self.conn.execute("SET session_replication_role = replica")
        try:
            self.conn.execute("DELETE FROM clinical.encounter_locations")
        finally:
            self.conn.execute("SET session_replication_role = origin")

    def count(self, table: str, where: str = "true", params=()) -> int:
        return self.one(f"SELECT count(*) FROM {table} WHERE {where}", params)


@pytest.fixture(scope="module")
def world():
    admin = psycopg.connect(_dsn("postgres"), autocommit=True)
    admin.execute(f'DROP DATABASE IF EXISTS "{TEST_DB}" WITH (FORCE)')
    for attempt in range(10):   # la plantilla no admite otras conexiones: reintenta
        try:
            admin.execute(f'CREATE DATABASE "{TEST_DB}" TEMPLATE "{TEMPLATE_DB}"')
            break
        except pgerr.ObjectInUse:
            time.sleep(1.5)
    else:
        pytest.fail(f"no se pudo clonar {TEMPLATE_DB}: sigue en uso")
    w = World(TEST_DB)
    w.seed_scaffold()
    try:
        yield w
    finally:
        w.conn.close()
        if not os.environ.get("F3_KEEP_DB"):
            admin.execute(f'DROP DATABASE IF EXISTS "{TEST_DB}" WITH (FORCE)')
        admin.close()


@pytest.fixture(scope="module")
def patched(world: World):
    """Deja el parche aplicado sobre datos heredados válidos (si la secuencia A→B no lo hizo ya)."""
    if not world.patched():
        world.wipe_locations()
        _seed_valid_legacy(world)
        res = world.apply_patch()
        assert res.returncode == 0, res.stderr
    return world


def _seed_valid_legacy(w: World) -> None:
    # E1 estuvo en B1 y se trasladó a B2; E2 ocupa B1; E3 y E4 comparten el local R1 (no es cama).
    w.legacy_loc(ENC[1], BED[1], "COMPLETED", day(0), day(2))
    w.legacy_loc(ENC[1], BED[2], "ACTIVE", day(2))
    w.legacy_loc(ENC[2], BED[1], "ACTIVE", day(2))
    w.legacy_loc(ENC[3], R1, "ACTIVE", day(0))
    w.legacy_loc(ENC[4], R1, "ACTIVE", day(1))


# ============================================================================ A. el patch aborta con datos incompatibles
class TestAAbortsOnIncompatibleData:
    """Antes del parche. Cada caso deja la base como la encontró (el BEGIN del patch hace rollback)."""

    @staticmethod
    def _untouched(w: World) -> None:
        assert not w.has_column("encounter_locations", "is_bed_assignment"), "el patch dejó columnas pese a abortar"
        assert not w.has_column("encounter_locations", "tenant_id")
        assert not w.has_column("encounters", "level_of_care_concept_id")
        assert w.one("SELECT to_regclass('clinical.placement_incidents')") is None
        assert w.one("SELECT to_regclass('audit.encounter_locations_history')") is None

    def test_01_patch_needs_f1b(self, world: World) -> None:
        res = run_psql(world.db, cmds=["BEGIN", "ALTER FUNCTION audit.structure_history_close_only() RENAME TO structure_history_close_only_x"],
                       files=[PATCH])
        assert res.returncode != 0
        assert "requiere F1 y F1b" in res.stderr
        assert world.one("SELECT to_regprocedure('audit.structure_history_close_only()')") is not None   # el rename se deshizo
        self._untouched(world)

    def test_02_two_patients_overlapping_in_a_legacy_bed(self, world: World) -> None:
        a = world.legacy_loc(ENC[1], BED[1], "ACTIVE", day(0))
        b = world.legacy_loc(ENC[2], BED[1], "ACTIVE", day(1))
        res = world.apply_patch()
        assert res.returncode != 0
        assert "pacientes solapados en la misma cama" in res.stderr
        assert a in res.stderr and b in res.stderr          # el mensaje nombra las filas en conflicto
        assert "no se toca ningún dato" in res.stderr
        self._untouched(world)
        world.wipe_locations()

    def test_03_encounter_in_two_beds_at_once(self, world: World) -> None:
        world.legacy_loc(ENC[3], BED[1], "COMPLETED", day(0), day(5))
        world.legacy_loc(ENC[3], BED[2], "ACTIVE", day(3))
        res = world.apply_patch()
        assert res.returncode != 0
        assert "encuentros en dos camas a la vez" in res.stderr
        self._untouched(world)
        world.wipe_locations()

    def test_04_two_active_bed_rows_for_one_encounter(self, world: World) -> None:
        world.legacy_loc(ENC[3], BED[1], "ACTIVE", day(0), day(1))     # ACTIVE con fin: no solapa con la siguiente
        world.legacy_loc(ENC[3], BED[2], "ACTIVE", day(2))
        res = world.apply_patch()
        assert res.returncode != 0
        assert "más de una ubicación de cama ACTIVA" in res.stderr
        self._untouched(world)
        world.wipe_locations()

    def test_05_bed_row_ends_before_it_starts(self, world: World) -> None:
        world.legacy_loc(ENC[3], BED[1], "COMPLETED", day(5), day(2))
        res = world.apply_patch()
        assert res.returncode != 0
        assert "period_end anterior a period_start" in res.stderr
        self._untouched(world)
        world.wipe_locations()

    def test_06_bed_row_without_period_start(self, world: World) -> None:
        world.legacy_loc(ENC[3], BED[1], "ACTIVE", None)
        res = world.apply_patch()
        assert res.returncode != 0
        assert "sin inicio de período o sin espacio" in res.stderr
        self._untouched(world)
        world.wipe_locations()

    def test_07_location_pointing_to_another_tenants_space(self, world: World) -> None:
        # encuentro del tenant 1 ubicado en la sede/cama del tenant 2: la FK compuesta no podría crearse
        world.legacy_loc(ENC[3], BX, "ACTIVE", day(0), site=S2)
        res = world.apply_patch()
        assert res.returncode != 0
        assert "OTRO tenant" in res.stderr
        assert "encounter_locations.practice_site_id" in res.stderr and "encounter_locations.care_space_id" in res.stderr
        self._untouched(world)
        world.wipe_locations()


# ============================================================================ B. aplica sobre datos válidos, y dos veces
class TestBApplyTwice:
    def test_10_applies_on_valid_legacy_data_and_backfills(self, world: World) -> None:
        world.wipe_locations()
        _seed_valid_legacy(world)
        before = world.count("clinical.encounter_locations")
        res = world.apply_patch()
        assert res.returncode == 0, res.stderr
        assert "infraestructura F3 aplicada" in res.stderr
        assert world.count("clinical.encounter_locations") == before == 5      # no pierde ni inventa filas
        # tenant_id = el del encuentro, ninguna fila sin tenant
        assert world.count("clinical.encounter_locations", "tenant_id IS NULL") == 0
        assert world.count("clinical.encounter_locations", "tenant_id = %s", (T1,)) == 5
        # camas marcadas por la forma del espacio; el local R1 no
        assert world.count("clinical.encounter_locations", "is_bed_assignment") == 3
        assert world.count("clinical.encounter_locations", "NOT is_bed_assignment AND care_space_id = %s", (R1,)) == 2
        # las 7 tablas con RLS, las 3 EXCLUDE diferibles
        assert world.one("SELECT count(*) FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass "
                         "AND contype = 'x' AND condeferrable AND NOT condeferred") == 3
        world.fp_after_first = world.fingerprint()

    def test_11_second_application_changes_nothing(self, world: World) -> None:
        assert world.fp_after_first, "depende de test_10"
        rows_before = world.all("SELECT id, tenant_id, is_bed_assignment, row_version FROM clinical.encounter_locations ORDER BY id")
        res = world.apply_patch()
        assert res.returncode == 0, res.stderr
        assert "infraestructura F3 aplicada" in res.stderr
        assert world.fingerprint() == world.fp_after_first
        assert world.all("SELECT id, tenant_id, is_bed_assignment, row_version FROM clinical.encounter_locations ORDER BY id") == rows_before

    def test_12_a_third_application_with_the_idempotence_of_the_catalog(self, world: World) -> None:
        res = world.apply_patch()
        assert res.returncode == 0, res.stderr
        assert world.fingerprint() == world.fp_after_first


# ============================================================================ C. rebuild deja los EXCLUDE inmediatos
class TestCRebuildLeavesImmediateExcludes:
    def test_20_patch_recreates_deferrable_excludes(self, world: World, patched: World) -> None:
        # Lo que deja SQL/08_clinical/05_constraints.sql (gen_integrity): DROP IF EXISTS + ADD sin DEFERRABLE.
        defs = {r[0]: r[1] for r in world.all("SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint "
                                              "WHERE conrelid = 'clinical.encounter_locations'::regclass AND contype = 'x'")}
        assert len(defs) == 3
        for name, d in defs.items():
            world.conn.execute(f'ALTER TABLE clinical.encounter_locations DROP CONSTRAINT "{name}"')
            world.conn.execute(f'ALTER TABLE clinical.encounter_locations ADD CONSTRAINT "{name}" {re.sub(r"\s+DEFERRABLE( INITIALLY (IMMEDIATE|DEFERRED))?$", "", d)}')
        assert world.one("SELECT count(*) FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass "
                         "AND contype = 'x' AND NOT condeferrable") == 3
        res = world.apply_patch()
        assert res.returncode == 0, res.stderr
        assert world.one("SELECT count(*) FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass "
                         "AND contype = 'x' AND condeferrable AND NOT condeferred") == 3
        assert {r[0]: r[1] for r in world.all("SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint "
                                              "WHERE conrelid = 'clinical.encounter_locations'::regclass AND contype = 'x'")} == defs
        assert world.fingerprint() == world.fp_after_first


# ============================================================================ D. comportamiento
def _free_beds(w: World) -> None:
    """Las camas B3..B6 libres y E3..E8 sin cama (las pruebas usan transacciones que se revierten)."""
    assert w.count("clinical.encounter_locations", "is_bed_assignment AND care_space_id = ANY(%s::uuid[])", ([BED[3], BED[4], BED[5], BED[6]],)) == 0


class TestDBedOccupancy:
    def test_30_two_patients_cannot_hold_the_same_bed(self, world: World, patched: World) -> None:
        _free_beds(world)
        with world.conn.transaction(force_rollback=True):
            world.loc(world.conn, ENC[3], BED[3], "ACTIVE", day(10))
            with pytest.raises(pgerr.ExclusionViolation) as ei:
                with world.conn.transaction():
                    world.loc(world.conn, ENC[4], BED[3], "ACTIVE", day(11))
            assert ei.value.diag.constraint_name == "ex_encounter_locations_bed_occupancy"
            assert ei.value.sqlstate == "23P01"
            assert world.count("clinical.encounter_locations", "care_space_id = %s AND location_status_concept_id = %s", (BED[3], C["ACTIVE"])) == 1

    def test_31_a_direct_insert_that_overlaps_is_rejected_even_for_the_owner(self, world: World, patched: World) -> None:
        # B1 la ocupa E2 desde el día 2 (dato heredado): un insert directo que solape → 23P01
        with pytest.raises(pgerr.ExclusionViolation):
            world.loc(world.conn, ENC[5], BED[1], "ACTIVE", day(3))
        with pytest.raises(pgerr.ExclusionViolation):
            world.loc(world.conn, ENC[5], BED[1], "RESERVED", day(20))      # una reserva también ocupa la cama

    def test_32_half_open_periods_back_to_back_are_allowed(self, world: World, patched: World) -> None:
        with world.conn.transaction(force_rollback=True):
            world.loc(world.conn, ENC[3], BED[3], "COMPLETED", day(10), day(12))
            world.loc(world.conn, ENC[4], BED[3], "ACTIVE", day(12))            # [10,12) y [12,∞): no solapan
            with pytest.raises(pgerr.ExclusionViolation):
                with world.conn.transaction():
                    world.loc(world.conn, ENC[5], BED[3], "ACTIVE", day(11))    # cae dentro de [10,12)

    def test_33_reserved_cancelled_and_non_bed_rows(self, world: World, patched: World) -> None:
        with world.conn.transaction(force_rollback=True):
            world.loc(world.conn, ENC[3], BED[3], "RESERVED", day(10))
            with pytest.raises(pgerr.ExclusionViolation):
                with world.conn.transaction():
                    world.loc(world.conn, ENC[4], BED[3], "ACTIVE", day(10))    # la reserva retiene la cama
        with world.conn.transaction(force_rollback=True):
            world.loc(world.conn, ENC[3], BED[4], "CANCELLED", day(10))
            world.loc(world.conn, ENC[4], BED[4], "ACTIVE", day(10))            # una reserva cancelada no bloquea
            # filas que no son cama (consultorio/local) pueden coexistir: es el comportamiento de siempre
            world.loc(world.conn, ENC[5], R1, "ACTIVE", day(10), bed=False)
            world.loc(world.conn, ENC[6], R1, "ACTIVE", day(10), bed=False)

    def test_34_one_encounter_one_bed_at_a_time(self, world: World, patched: World) -> None:
        with world.conn.transaction(force_rollback=True):
            world.loc(world.conn, ENC[3], BED[3], "ACTIVE", day(10))
            with pytest.raises(pgerr.ExclusionViolation) as ei:
                with world.conn.transaction():
                    world.loc(world.conn, ENC[3], BED[4], "ACTIVE", day(11))
            assert ei.value.diag.constraint_name in ("ex_encounter_locations_encounter_single_bed",
                                                     "ex_encounter_locations_encounter_one_active_bed")
            # la reserva de traslado SÍ puede convivir con la cama actual del mismo encuentro
            world.loc(world.conn, ENC[3], BED[4], "RESERVED", day(11))

    def test_35_at_most_one_active_bed_row_per_encounter(self, world: World, patched: World) -> None:
        with world.conn.transaction(force_rollback=True):
            world.loc(world.conn, ENC[3], BED[3], "ACTIVE", day(10), day(11))   # ACTIVE con fin (la API debió cerrarla)
            with pytest.raises(pgerr.ExclusionViolation) as ei:
                with world.conn.transaction():
                    world.loc(world.conn, ENC[3], BED[4], "ACTIVE", day(12))    # disjunta en el tiempo pero 2.º ACTIVE
            assert ei.value.diag.constraint_name == "ex_encounter_locations_encounter_one_active_bed"

    def test_36_bed_row_checks(self, world: World, patched: World) -> None:
        with world.conn.transaction(force_rollback=True):
            with pytest.raises(pgerr.CheckViolation) as ei:
                with world.conn.transaction():
                    world.loc(world.conn, ENC[3], BED[3], "ACTIVE", None)
            assert ei.value.diag.constraint_name == "ck_encounter_locations_bed_period"
            # sin espacio, la bandera se deriva a false (ya no es cama): el CHECK queda como defensa en profundidad
            nb = world.loc(world.conn, ENC[3], None, "ACTIVE", day(10))
            assert world.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (nb,)) is False
            with pytest.raises(pgerr.CheckViolation) as ei:
                with world.conn.transaction():
                    world.loc(world.conn, ENC[3], BED[3], "COMPLETED", day(10), day(9))
            assert ei.value.diag.constraint_name == "ck_encounter_locations_bed_period_order"
            # una fila que no es cama conserva la libertad de antes (período vacío, sin espacio)
            world.loc(world.conn, ENC[3], None, "ACTIVE", None, bed=False)

    def test_37_concurrent_double_booking_exactly_one_wins(self, world: World, patched: World) -> None:
        """Dos transacciones REALES asignan la misma cama a la vez: una espera, la otra confirma y la primera falla."""
        _free_beds(world)
        a = psycopg.connect(_dsn(world.db), autocommit=False)
        outcome: dict = {}

        def second() -> None:
            b = psycopg.connect(_dsn(world.db), autocommit=False)
            try:
                outcome["b_pid"] = b.info.backend_pid
                world.loc(b, ENC[4], BED[5], "ACTIVE", day(30))
                b.commit()
                outcome["b"] = "ok"
            except pgerr.ExclusionViolation as exc:
                b.rollback()
                outcome["b"] = ("23P01", exc.diag.constraint_name)
            finally:
                b.close()

        try:
            world.loc(a, ENC[3], BED[5], "ACTIVE", day(30))                  # A: inserta, SIN confirmar
            th = threading.Thread(target=second)
            th.start()
            deadline = time.time() + 10
            waiting = False
            while time.time() < deadline and not waiting:                    # B queda bloqueada esperando a A
                time.sleep(0.2)
                if "b_pid" in outcome:
                    waiting = bool(world.one("SELECT count(*) FROM pg_stat_activity WHERE pid = %s AND wait_event_type = 'Lock'",
                                             (outcome["b_pid"],)))
            assert waiting, "B no quedó esperando el candado de A"
            assert th.is_alive() and "b" not in outcome
            a.commit()                                                       # A confirma → B se despierta y falla
            th.join(10)
            assert outcome["b"] == ("23P01", "ex_encounter_locations_bed_occupancy")
            rows = world.all("SELECT encounter_id FROM clinical.encounter_locations WHERE care_space_id = %s AND is_bed_assignment", (BED[5],))
            assert rows == [(uuid.UUID(ENC[3]),)]                            # en la base hay UNA sola fila activa
        finally:
            a.close()
            world.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = %s", (BED[5],))

    def test_38_concurrent_rollback_lets_the_waiter_through(self, world: World, patched: World) -> None:
        a = psycopg.connect(_dsn(world.db), autocommit=False)
        outcome: dict = {}

        def second() -> None:
            b = psycopg.connect(_dsn(world.db), autocommit=False)
            try:
                outcome["b_pid"] = b.info.backend_pid
                world.loc(b, ENC[4], BED[5], "ACTIVE", day(30))
                b.commit()
                outcome["b"] = "ok"
            except Exception as exc:  # noqa: BLE001
                outcome["b"] = repr(exc)
            finally:
                b.close()

        try:
            world.loc(a, ENC[3], BED[5], "ACTIVE", day(30))
            th = threading.Thread(target=second)
            th.start()
            time.sleep(1.0)
            assert th.is_alive()
            a.rollback()
            th.join(10)
            assert outcome["b"] == "ok"
            assert world.all("SELECT encounter_id FROM clinical.encounter_locations WHERE care_space_id = %s", (BED[5],)) == [(uuid.UUID(ENC[4]),)]
        finally:
            a.close()
            world.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = %s", (BED[5],))


class TestETransferAndSwap:
    def _active_rows(self, w: World, enc: str):
        return w.all("SELECT care_space_id, period_end FROM clinical.encounter_locations WHERE encounter_id = %s AND is_bed_assignment "
                     "AND location_status_concept_id = %s", (enc, C["ACTIVE"]))

    def test_40_transfer_leaves_one_active_record(self, world: World, patched: World) -> None:
        w = world
        try:
            origin = w.loc(w.conn, ENC[5], BED[3], "ACTIVE", day(40), movement_type_concept_id=C["ADT_ADMIT"])
            t = day(45)
            with w.conn.transaction():          # traslado atómico: cierra origen, abre destino
                w.conn.execute("UPDATE clinical.encounter_locations SET period_end = %s, location_status_concept_id = %s, "
                               "end_reason_concept_id = %s WHERE id = %s", (t, C["COMPLETED"], C["END_TRANSFER_OUT"], origin))
                dest = w.loc(w.conn, ENC[5], BED[4], "ACTIVE", t, movement_type_concept_id=C["ADT_TRANSFER"],
                             previous_encounter_location_id=origin)
            assert self._active_rows(w, ENC[5]) == [(uuid.UUID(BED[4]), None)]        # un solo registro activo
            assert w.one("SELECT location_status_concept_id FROM clinical.encounter_locations WHERE id = %s", (origin,)) == uuid.UUID(C["COMPLETED"])
            assert w.one("SELECT period_end FROM clinical.encounter_locations WHERE id = %s", (origin,)) == t
            assert w.one("SELECT previous_encounter_location_id FROM clinical.encounter_locations WHERE id = %s", (dest,)) == uuid.UUID(origin)
            # la cama de origen quedó libre para otro paciente desde t
            w.loc(w.conn, ENC[6], BED[3], "ACTIVE", t)
            assert w.count("clinical.encounter_locations", "encounter_id = %s AND is_bed_assignment", (ENC[5],)) == 2
        finally:
            w.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = ANY(%s::uuid[])", ([BED[3], BED[4]],))

    def test_41_a_failing_transfer_changes_nothing(self, world: World, patched: World) -> None:
        w = world
        try:
            origin = w.loc(w.conn, ENC[5], BED[3], "ACTIVE", day(40))
            w.loc(w.conn, ENC[6], BED[4], "ACTIVE", day(40))                          # destino ya ocupado
            snapshot = w.all("SELECT id, period_end, location_status_concept_id, row_version FROM clinical.encounter_locations ORDER BY id")
            with pytest.raises(pgerr.ExclusionViolation):
                with w.conn.transaction():
                    w.conn.execute("UPDATE clinical.encounter_locations SET period_end = %s, location_status_concept_id = %s WHERE id = %s",
                                   (day(45), C["COMPLETED"], origin))
                    w.loc(w.conn, ENC[5], BED[4], "ACTIVE", day(45))                  # falla a mitad
            assert w.all("SELECT id, period_end, location_status_concept_id, row_version FROM clinical.encounter_locations ORDER BY id") == snapshot
            assert self._active_rows(w, ENC[5]) == [(uuid.UUID(BED[3]), None)]        # sigue en su cama, abierta
        finally:
            w.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = ANY(%s::uuid[])", ([BED[3], BED[4]],))

    def test_42_opening_the_destination_first_needs_deferred_constraints(self, world: World, patched: World) -> None:
        w = world
        try:
            origin = w.loc(w.conn, ENC[5], BED[3], "ACTIVE", day(40))
            t = day(45)
            with pytest.raises(pgerr.ExclusionViolation):                              # inmediato: el destino solapa con el origen abierto
                with w.conn.transaction():
                    w.loc(w.conn, ENC[5], BED[4], "ACTIVE", t)
            with w.conn.transaction():                                                 # diferido: el orden de las sentencias da igual
                w.conn.execute("SET CONSTRAINTS clinical.ex_encounter_locations_bed_occupancy, clinical.ex_encounter_locations_encounter_single_bed, "
                               "clinical.ex_encounter_locations_encounter_one_active_bed DEFERRED")
                w.loc(w.conn, ENC[5], BED[4], "ACTIVE", t)
                w.conn.execute("UPDATE clinical.encounter_locations SET period_end = %s, location_status_concept_id = %s WHERE id = %s",
                               (t, C["COMPLETED"], origin))
            assert self._active_rows(w, ENC[5]) == [(uuid.UUID(BED[4]), None)]
        finally:
            w.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = ANY(%s::uuid[])", ([BED[3], BED[4]],))

    def test_43_a17_swap_between_two_occupied_beds(self, world: World, patched: World) -> None:
        w = world
        try:
            a_old = w.loc(w.conn, ENC[5], BED[3], "ACTIVE", day(40))
            b_old = w.loc(w.conn, ENC[6], BED[4], "ACTIVE", day(41))
            t = day(50)
            with pytest.raises(pgerr.ExclusionViolation):                              # sin diferir, abrir antes de cerrar falla
                with w.conn.transaction():
                    w.loc(w.conn, ENC[5], BED[4], "ACTIVE", t)
            with w.conn.transaction():
                w.conn.execute("SET CONSTRAINTS clinical.ex_encounter_locations_bed_occupancy, clinical.ex_encounter_locations_encounter_single_bed, "
                               "clinical.ex_encounter_locations_encounter_one_active_bed DEFERRED")
                w.loc(w.conn, ENC[5], BED[4], "ACTIVE", t, movement_type_concept_id=C["ADT_SWAP"], previous_encounter_location_id=a_old)
                w.loc(w.conn, ENC[6], BED[3], "ACTIVE", t, movement_type_concept_id=C["ADT_SWAP"], previous_encounter_location_id=b_old)
                w.conn.execute("UPDATE clinical.encounter_locations SET period_end = %s, location_status_concept_id = %s WHERE id = ANY(%s::uuid[])",
                               (t, C["COMPLETED"], [a_old, b_old]))
            assert w.count("clinical.encounter_locations", "is_bed_assignment AND care_space_id = ANY(%s::uuid[])", ([BED[3], BED[4]],)) == 4
            assert self._active_rows(w, ENC[5]) == [(uuid.UUID(BED[4]), None)]
            assert self._active_rows(w, ENC[6]) == [(uuid.UUID(BED[3]), None)]
        finally:
            w.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = ANY(%s::uuid[])", ([BED[3], BED[4]],))

    def test_44_a_swap_that_leaves_two_in_one_bed_fails_at_commit(self, world: World, patched: World) -> None:
        w = world
        try:
            a_old = w.loc(w.conn, ENC[5], BED[3], "ACTIVE", day(40))
            b_old = w.loc(w.conn, ENC[6], BED[4], "ACTIVE", day(41))
            t = day(50)
            with pytest.raises(pgerr.ExclusionViolation):
                with w.conn.transaction():
                    w.conn.execute("SET CONSTRAINTS clinical.ex_encounter_locations_bed_occupancy DEFERRED")
                    w.loc(w.conn, ENC[5], BED[4], "ACTIVE", t)
                    w.loc(w.conn, ENC[6], BED[4], "ACTIVE", t)                         # ambos a B4: ningún orden lo arregla
                    w.conn.execute("UPDATE clinical.encounter_locations SET period_end = %s, location_status_concept_id = %s WHERE id = ANY(%s::uuid[])",
                                   (t, C["COMPLETED"], [a_old, b_old]))
            assert self._active_rows(w, ENC[5]) == [(uuid.UUID(BED[3]), None)]
            assert self._active_rows(w, ENC[6]) == [(uuid.UUID(BED[4]), None)]
        finally:
            w.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = ANY(%s::uuid[])", ([BED[3], BED[4]],))


@pytest.fixture()
def as_app(world: World):
    """Transacción que se revierte y en la que se puede `SET LOCAL ROLE mantra_app` + contexto de tenant."""
    def enter(tenant: str | None):
        world.conn.execute("SET LOCAL ROLE mantra_app")
        if tenant:
            world.conn.execute("SELECT set_config('app.current_tenant_id', %s, true)", (tenant,))
    return enter


class TestFTenantIsolation:
    def test_50_rls_is_forced_on_the_seven_tables(self, world: World, patched: World) -> None:
        rows = world.all("SELECT n.nspname || '.' || c.relname, c.relrowsecurity, c.relforcerowsecurity, "
                         "(SELECT count(*) FROM pg_policies p WHERE p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation') "
                         "FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname || '.' || c.relname = ANY(%s) ORDER BY 1",
                         (["clinical.encounter_locations", "clinical.placement_incidents", "clinical.inpatient_census_days",
                           "clinical.inpatient_census_entries", "clinical.inpatient_census_adjustments",
                           "audit.encounter_locations_history", "audit.placement_incidents_history"],))
        assert len(rows) == 7
        assert all(r[1] and r[2] and r[3] == 1 for r in rows), rows

    def test_51_a_tenant_only_sees_and_writes_its_own_locations(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            w.conn.execute(
                "INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, "
                "created_at, updated_at, is_bed_assignment) VALUES (%s, %s, %s, %s, %s, %s, now(), now(), true)",
                (str(uuid.uuid4()), ENC[9], S2, BX, C["ACTIVE"], day(60)))
            w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(60))
            assert w.count("clinical.encounter_locations", "tenant_id = %s", (T2,)) == 1
            as_app(T1)
            assert w.count("clinical.encounter_locations", "tenant_id = %s", (T2,)) == 0           # el tenant 2 no existe para el 1
            assert w.count("clinical.encounter_locations") == 6                                    # 5 heredadas + 1
            # escribir como tenant 2 estando en el contexto del 1 → RLS lo rechaza
            with pytest.raises(pgerr.InsufficientPrivilege):
                with w.conn.transaction():
                    w.loc(w.conn, ENC[9], BX, "ACTIVE", day(70), tenant_id=T2, practice_site_id=S2)
            # UPDATE sobre una fila ajena: ninguna fila afectada
            cur = w.conn.execute("UPDATE clinical.encounter_locations SET period_end = %s WHERE tenant_id = %s", (day(99), T2))
            assert cur.rowcount == 0

    def test_52_without_tenant_context_it_fails_closed(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            as_app(None)
            assert w.count("clinical.encounter_locations") == 0
            with pytest.raises(pgerr.InsufficientPrivilege):
                with w.conn.transaction():
                    w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(60), tenant_id=T1)

    def test_53_the_old_writer_still_works_and_the_trigger_fills_the_tenant(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            as_app(T1)
            lid = str(uuid.uuid4())
            # exactamente las columnas con las que EncountersService.checkIn escribía antes de F3
            w.conn.execute("INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, "
                           "period_start, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, now(), now())",
                           (lid, ENC[7], S1, R1, C["ACTIVE"], day(60)))
            assert w.one("SELECT tenant_id FROM clinical.encounter_locations WHERE id = %s", (lid,)) == uuid.UUID(T1)
            assert w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (lid,)) is False

    def test_54_composite_foreign_keys_reject_cross_tenant_references(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            # encuentro del tenant 1 en una cama del tenant 2 (la FK simple pasaría; la compuesta no)
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    w.loc(w.conn, ENC[3], BX, "ACTIVE", day(60))
            assert ei.value.diag.constraint_name == "fk_encounter_locations_tenant_space"
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(60), practice_site_id=S2)
            assert ei.value.diag.constraint_name == "fk_encounter_locations_tenant_site"
            # tenant_id explícito que no es el del encuentro
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    w.loc(w.conn, ENC[9], BED[3], "ACTIVE", day(60), tenant_id=T1)
            assert ei.value.diag.constraint_name == "fk_encounter_locations_tenant_encounter"
            # ubicación previa de otro tenant
            other = str(uuid.uuid4())
            w.conn.execute("INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, "
                           "period_start, created_at, updated_at, is_bed_assignment) VALUES (%s, %s, %s, %s, %s, %s, now(), now(), true)",
                           (other, ENC[9], S2, BX, C["ACTIVE"], day(60)))
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(60), previous_encounter_location_id=other)
            assert ei.value.diag.constraint_name == "fk_encounter_locations_tenant_previous"


def _incident(w: World, *, enc=None, loc=None, space=None, patient=None, tenant=None, text="El paciente requiere esta cama por indicación médica.",
              violations='[{"rule": "SEX", "detail": "habitación femenina"}]') -> str:
    iid = str(uuid.uuid4())
    w.conn.execute(
        "INSERT INTO clinical.placement_incidents (id, tenant_id, encounter_id, encounter_location_id, care_space_id, patient_profile_id, violations_json, "
        "justification_text, authorized_by_user_id, status_concept_id, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s::jsonb, %s, %s, %s, now(), now())",
        (iid, tenant or T1, enc or ENC[3], loc, space or BED[3], patient or PAT[3], violations, text, U1, C["PLC_INC_OPEN"]))
    return iid


class TestGPlacementIncidents:
    def test_60_justification_needs_20_characters(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            _incident(w, text="x" * 20)
            for bad in ("x" * 19, "", "   " + "x" * 10 + "   "):      # los espacios de borde no cuentan
                with pytest.raises(pgerr.CheckViolation) as ei:
                    with w.conn.transaction():
                        _incident(w, text=bad)
                assert ei.value.diag.constraint_name == "ck_placement_incidents_justification_length", bad

    def test_61_violations_must_be_a_json_array(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            for bad in ('{"rule": "SEX"}', '"SEX"', "null::text"):
                with pytest.raises((pgerr.CheckViolation, pgerr.NotNullViolation, pgerr.InvalidTextRepresentation, pgerr.SyntaxError)):
                    with w.conn.transaction():
                        _incident(w, violations=bad)

    def test_62_incident_and_location_link_both_ways_in_one_transaction(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            loc = w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(70), bed_category_concept_id=C["BED_CAT_ICU"], movement_type_concept_id=C["ADT_ADMIT"])
            iid = _incident(w, loc=loc, space=BED[3])
            w.conn.execute("UPDATE clinical.encounter_locations SET placement_incident_id = %s WHERE id = %s", (iid, loc))
            assert w.one("SELECT placement_incident_id FROM clinical.encounter_locations WHERE id = %s", (loc,)) == uuid.UUID(iid)
            assert w.one("SELECT encounter_location_id FROM clinical.placement_incidents WHERE id = %s", (iid,)) == uuid.UUID(loc)

    def test_63_incident_cannot_reference_another_tenants_encounter_or_space(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    _incident(w, enc=ENC[9], patient=PAT[9])           # encuentro del tenant 2, incidente del 1
            assert ei.value.diag.constraint_name == "fk_placement_incidents_tenant_encounter"
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    _incident(w, space=BX)
            assert ei.value.diag.constraint_name == "fk_placement_incidents_tenant_space"

    def test_64_incidents_are_isolated_by_rls(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            _incident(w)
            _incident(w, enc=ENC[9], space=BX, patient=PAT[9], tenant=T2)
            as_app(T2)
            assert w.count("clinical.placement_incidents") == 1
            assert w.count("clinical.placement_incidents", "tenant_id = %s", (T1,)) == 0


def _census_day(w: World, *, date: dt.date = dt.date(2026, 10, 20), site=S1, unit=UN1, tenant=T1, closed: bool = False,
                censable=10, available=8, blocked=2) -> str:
    did = str(uuid.uuid4())
    w.conn.execute(
        "INSERT INTO clinical.inpatient_census_days (id, tenant_id, practice_site_id, clinical_unit_id, census_date, cutoff_at, status_concept_id, "
        "closed_at, content_hash, beds_censable, beds_available, beds_blocked, patients_at_cutoff, admissions, discharges, deaths, transfers_in, "
        "transfers_out, same_day_stays, patient_days, discharge_stay_days, created_at, updated_at) "
        "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 6, 3, 2, 0, 1, 1, 1, 7, 9, now(), now())",
        (did, tenant, site, unit, date, dt.datetime.combine(date + dt.timedelta(days=1), dt.time(), tzinfo=dt.timezone.utc),
         C["CENSUS_CLOSED"] if closed else C["CENSUS_OPEN"], dt.datetime.now(dt.timezone.utc) if closed else None,
         "sha256:abc" if closed else None, censable, available, blocked))
    return did


def _entry(w: World, day_id: str, tenant=T1, enc=None, patient=None, space=BED[3]) -> str:
    eid = str(uuid.uuid4())
    w.conn.execute("INSERT INTO clinical.inpatient_census_entries (id, tenant_id, census_day_id, encounter_id, patient_profile_id, care_space_id, "
                   "bed_category_concept_id, movement_concept_id, occurred_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, now())",
                   (eid, tenant, day_id, enc or ENC[3], patient or PAT[3], space, C["BED_CAT_ICU"], C["CEN_PRESENT"]))
    return eid


def _adjust(w: World, day_id: str, *, field="patient_days", prev=7, new=8, reason="Reingreso omitido en el corte", entry=None, tenant=T1) -> str:
    aid = str(uuid.uuid4())
    w.conn.execute("INSERT INTO clinical.inpatient_census_adjustments (id, tenant_id, census_day_id, field_code, previous_value, new_value, "
                   "reason_text, entry_ref_id, adjusted_by_user_id, request_id, created_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'req-1', now())",
                   (aid, tenant, day_id, field, prev, new, reason, entry, U1))
    return aid


class TestHCensus:
    def test_70_one_census_per_site_unit_and_date(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            _census_day(w)
            _census_day(w, date=dt.date(2026, 10, 21))
            with pytest.raises(pgerr.UniqueViolation) as ei:
                with w.conn.transaction():
                    _census_day(w)
            assert ei.value.diag.constraint_name == "ux_inpatient_census_days_site_unit_date"

    def test_71_counts_must_be_consistent(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            with pytest.raises(pgerr.CheckViolation) as ei:
                with w.conn.transaction():
                    _census_day(w, censable=10, available=8, blocked=1)       # beds_blocked = censables − disponibles
            assert ei.value.diag.constraint_name == "ck_inpatient_census_days_counts"
            with pytest.raises(pgerr.CheckViolation):
                with w.conn.transaction():
                    _census_day(w, censable=-1, available=-1, blocked=0)

    def test_72_a_closed_census_cannot_be_updated_or_deleted(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d = _census_day(w)                                                  # abierto: se puede cerrar con UPDATE
            with pytest.raises(pgerr.CheckViolation) as ei:
                with w.conn.transaction():                                      # cerrado sin huella de contenido
                    w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), status_concept_id = %s WHERE id = %s", (C["CENSUS_CLOSED"], d))
            assert ei.value.diag.constraint_name == "ck_inpatient_census_days_closed_has_hash"
            w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'sha256:abc', status_concept_id = %s WHERE id = %s",
                           (C["CENSUS_CLOSED"], d))
            snapshot = w.all("SELECT * FROM clinical.inpatient_census_days WHERE id = %s", (d,))
            for stmt in ("UPDATE clinical.inpatient_census_days SET patient_days = patient_days + 1 WHERE id = %s",
                         "UPDATE clinical.inpatient_census_days SET closed_at = NULL, content_hash = NULL WHERE id = %s",
                         "UPDATE clinical.inpatient_census_days SET status_concept_id = '" + C["CENSUS_OPEN"] + "' WHERE id = %s",
                         "DELETE FROM clinical.inpatient_census_days WHERE id = %s"):
                with pytest.raises(pgerr.RestrictViolation) as ei:
                    with w.conn.transaction():
                        w.conn.execute(stmt, (d,))
                assert "inmutable" in str(ei.value)
            assert w.all("SELECT * FROM clinical.inpatient_census_days WHERE id = %s", (d,)) == snapshot

    def test_73_an_open_census_can_still_be_deleted(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d = _census_day(w)
            w.conn.execute("DELETE FROM clinical.inpatient_census_days WHERE id = %s", (d,))
            assert w.count("clinical.inpatient_census_days", "id = %s", (d,)) == 0

    def test_74_entries_and_adjustments_are_append_only(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d = _census_day(w)
            e = _entry(w, d)
            w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'h' WHERE id = %s", (d,))
            a = _adjust(w, d, entry=e)
            for table, rid in (("inpatient_census_entries", e), ("inpatient_census_adjustments", a)):
                for stmt in (f"UPDATE clinical.{table} SET tenant_id = tenant_id WHERE id = %s", f"DELETE FROM clinical.{table} WHERE id = %s"):
                    with pytest.raises(pgerr.RestrictViolation):
                        with w.conn.transaction():
                            w.conn.execute(stmt, (rid,))

    def test_75_adjustments_only_on_closed_days_and_never_touch_the_snapshot(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d = _census_day(w)
            with pytest.raises(pgerr.CheckViolation) as ei:
                with w.conn.transaction():
                    _adjust(w, d)                                              # día abierto → CENSUS_NOT_CLOSED
            assert "CENSUS_NOT_CLOSED" in str(ei.value)
            w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'h' WHERE id = %s", (d,))
            before = w.all("SELECT * FROM clinical.inpatient_census_days WHERE id = %s", (d,))
            _adjust(w, d)
            _adjust(w, d, new=9, prev=8)
            assert w.all("SELECT * FROM clinical.inpatient_census_days WHERE id = %s", (d,)) == before      # el snapshot no cambia
            assert w.count("clinical.inpatient_census_adjustments", "census_day_id = %s", (d,)) == 2
            for kw, cname in (({"field": "total_beds"}, "ck_inpatient_census_adjustments_field_code"),
                              ({"reason": "   "}, "ck_inpatient_census_adjustments_reason"),
                              ({"new": -1}, "ck_inpatient_census_adjustments_reason")):
                with pytest.raises(pgerr.CheckViolation) as ei:
                    with w.conn.transaction():
                        _adjust(w, d, **kw)
                assert ei.value.diag.constraint_name == cname

    def test_76_an_adjustment_can_only_cite_an_entry_of_its_own_day(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d1 = _census_day(w, date=dt.date(2026, 10, 20))
            d2 = _census_day(w, date=dt.date(2026, 10, 21))
            e2 = _entry(w, d2)
            for d in (d1, d2):
                w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'h' WHERE id = %s", (d,))
            with pytest.raises(pgerr.CheckViolation):
                with w.conn.transaction():
                    _adjust(w, d1, entry=e2)
            _adjust(w, d2, entry=e2)

    def test_77_census_rows_cannot_cross_tenants(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    _census_day(w, site=S2, unit=UN2)                          # tenant 1 sobre una sede/unidad del 2
            assert ei.value.diag.constraint_name in ("fk_inpatient_census_days_tenant_site", "fk_inpatient_census_days_tenant_unit")
            d = _census_day(w)
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    _entry(w, d, tenant=T2, enc=ENC[9], patient=PAT[9], space=BX)   # entrada del tenant 2 en el censo del 1
            assert "no existe para este tenant" in str(ei.value)       # el trigger va antes que la FK compuesta y no revela el día ajeno
            w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'h' WHERE id = %s", (d,))
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    _adjust(w, d, tenant=T2)
            assert ei.value.diag.constraint_name == "fk_inpatient_census_adjustments_tenant_day"

    def test_78_census_tables_are_isolated_by_rls_and_the_app_role_cannot_rewrite_them(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d1 = _census_day(w)
            d2 = _census_day(w, tenant=T2, site=S2, unit=UN2)
            e1 = _entry(w, d1)
            _entry(w, d2, tenant=T2, enc=ENC[9], patient=PAT[9], space=BX)
            as_app(T1)
            assert w.count("clinical.inpatient_census_days") == 1
            assert w.count("clinical.inpatient_census_entries") == 1
            assert w.count("clinical.inpatient_census_entries", "tenant_id = %s", (T2,)) == 0
            # mantra_app no tiene UPDATE ni DELETE sobre las tablas WORM (privilegio, además del trigger)
            for table in ("inpatient_census_entries", "inpatient_census_adjustments"):
                for stmt in (f"UPDATE clinical.{table} SET tenant_id = tenant_id", f"DELETE FROM clinical.{table}"):
                    with pytest.raises(pgerr.InsufficientPrivilege):
                        with w.conn.transaction():
                            w.conn.execute(stmt)
            assert e1


class TestIHistories:
    def _hist(self, w: World, table: str, col: str, source_id: str, tenant=None, rev=1) -> str:
        hid = str(uuid.uuid4())
        w.conn.execute(f"INSERT INTO audit.{table} (history_id, {col}, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at"
                       + (", tenant_id" if tenant else "") + ") VALUES (%s, %s, %s, %s, now(), %s::jsonb, now()" + (", %s" if tenant else "") + ")",
                       (hid, source_id, rev, C["OP_INSERT"], json.dumps({"id": source_id}), *( (tenant,) if tenant else () )))
        return hid

    def test_80_history_is_append_only_for_the_owner_and_for_the_app_role(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            loc = w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(80))
            h = self._hist(w, "encounter_locations_history", "encounter_location_id", loc)       # tenant lo completa el trigger
            assert w.one("SELECT tenant_id FROM audit.encounter_locations_history WHERE history_id = %s", (h,)) == uuid.UUID(T1)
            for stmt in ("DELETE FROM audit.encounter_locations_history WHERE history_id = %s",
                         "UPDATE audit.encounter_locations_history SET data_snapshot = '{}'::jsonb WHERE history_id = %s"):
                with pytest.raises(pgerr.RestrictViolation):
                    with w.conn.transaction():
                        w.conn.execute(stmt, (h,))
            w.conn.execute("UPDATE audit.encounter_locations_history SET valid_to = now() WHERE history_id = %s", (h,))   # cierre SCD-2
            with pytest.raises(pgerr.RestrictViolation):                                                                    # una sola vez
                with w.conn.transaction():
                    w.conn.execute("UPDATE audit.encounter_locations_history SET valid_to = now() WHERE history_id = %s", (h,))

    def test_81_app_role_can_insert_and_close_but_not_rewrite_history(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            iid = _incident(w)
            as_app(T1)
            h = self._hist(w, "placement_incidents_history", "placement_incident_id", iid)
            w.conn.execute("UPDATE audit.placement_incidents_history SET valid_to = now() WHERE history_id = %s", (h,))
            with pytest.raises(pgerr.InsufficientPrivilege):
                with w.conn.transaction():
                    w.conn.execute("UPDATE audit.placement_incidents_history SET data_snapshot = '{}'::jsonb WHERE history_id = %s", (h,))
            with pytest.raises(pgerr.InsufficientPrivilege):
                with w.conn.transaction():
                    w.conn.execute("DELETE FROM audit.placement_incidents_history WHERE history_id = %s", (h,))

    def test_82_history_is_isolated_by_tenant_and_cannot_point_across_tenants(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            loc1 = w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(80))
            loc2 = str(uuid.uuid4())
            w.conn.execute("INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, "
                           "created_at, updated_at, is_bed_assignment) VALUES (%s, %s, %s, %s, %s, %s, now(), now(), true)", (loc2, ENC[9], S2, BX, C["ACTIVE"], day(80)))
            self._hist(w, "encounter_locations_history", "encounter_location_id", loc1)
            self._hist(w, "encounter_locations_history", "encounter_location_id", loc2)
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    self._hist(w, "encounter_locations_history", "encounter_location_id", loc2, tenant=T1)
            assert ei.value.diag.constraint_name == "fk_encounter_locations_history_tenant_source"
            as_app(T2)
            assert w.count("audit.encounter_locations_history") == 1


class TestJEncountersColumns:
    def test_90_new_encounter_columns_exist_and_are_optional(self, world: World, patched: World) -> None:
        w = world
        cols = {r[0]: r[1] for r in w.all("SELECT column_name, is_nullable FROM information_schema.columns WHERE table_schema = 'clinical' "
                                          "AND table_name = 'encounters' AND column_name IN ('level_of_care_concept_id', 'admission_source_concept_id', "
                                          "'discharge_disposition_concept_id', 'isolation_precaution_concept_id', 'isolation_organism_text', 'expected_discharge_at')")}
        assert len(cols) == 6 and set(cols.values()) == {"YES"}
        with w.conn.transaction(force_rollback=True):
            w.conn.execute("UPDATE clinical.encounters SET level_of_care_concept_id = %s, admission_source_concept_id = %s, "
                           "discharge_disposition_concept_id = %s, isolation_precaution_concept_id = %s, isolation_organism_text = 'MRSA', "
                           "expected_discharge_at = now() WHERE id = %s", (C["ANY"], C["ANY"], C["ANY"], C["ANY"], ENC[3]))
            with pytest.raises(pgerr.ForeignKeyViolation):                       # son FK a catalog_concepts
                with w.conn.transaction():
                    w.conn.execute("UPDATE clinical.encounters SET level_of_care_concept_id = %s WHERE id = %s", (str(uuid.uuid4()), ENC[3]))


# ============================================================================ K. cierres de seguridad: fallar cerrado
def _owner_conn_cleanup(w: World, sql: str, params=()) -> None:
    """Borra filas que una prueba CONFIRMÓ (autocommit) saltando los triggers WORM; sólo superusuario de prueba."""
    w.conn.execute("SET session_replication_role = replica")
    try:
        w.conn.execute(sql, params)
    finally:
        w.conn.execute("SET session_replication_role = origin")


class TestKBedFlagIsDerived:
    """Hallazgo 1: is_bed_assignment no se le confía a quien llama (el predicado de los EXCLUDE depende de ella)."""

    def test_100_a_false_flag_on_a_real_bed_is_overridden_and_still_excluded(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            first = w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(90), bed=True)
            spoof = w.loc(w.conn, ENC[3], BED[4], "RESERVED", day(90), bed=False)        # false sobre una cama real
            assert w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (spoof,)) is True
            with pytest.raises(pgerr.ExclusionViolation) as ei:                           # el bypass de «dos pacientes, una cama»
                with w.conn.transaction():
                    w.loc(w.conn, ENC[4], BED[3], "ACTIVE", day(91), bed=False)
            assert ei.value.diag.constraint_name == "ex_encounter_locations_bed_occupancy"
            assert first

    def test_101_a_true_flag_on_a_room_or_without_space_is_overridden_to_false(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            room = w.loc(w.conn, ENC[3], R1, "ACTIVE", day(90), bed=True)
            nospace = w.loc(w.conn, ENC[4], None, "ACTIVE", None, bed=True)
            for rid in (room, nospace):
                assert w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (rid,)) is False
            # un local (no cama) no entra en los EXCLUDE: dos encuentros en el mismo local siguen siendo válidos
            w.loc(w.conn, ENC[5], R1, "ACTIVE", day(90), bed=True)

    def test_102_the_flag_is_rederived_on_update_when_the_space_or_the_flag_change(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            lid = w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(90))
            flag = lambda: w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (lid,))
            assert flag() is True
            w.conn.execute("UPDATE clinical.encounter_locations SET is_bed_assignment = false WHERE id = %s", (lid,))
            assert flag() is True                                                          # no se puede apagar a mano
            w.conn.execute("UPDATE clinical.encounter_locations SET care_space_id = %s WHERE id = %s", (R1, lid))
            assert flag() is False                                                         # cambió de espacio: se re-deriva
            w.conn.execute("UPDATE clinical.encounter_locations SET care_space_id = %s, is_bed_assignment = false WHERE id = %s", (BED[4], lid))
            assert flag() is True
            # mover a una cama ocupada por otro paciente se rechaza aunque la bandera viaje en false
            w.loc(w.conn, ENC[4], BED[5], "ACTIVE", day(90))
            with pytest.raises(pgerr.ExclusionViolation):
                with w.conn.transaction():
                    w.conn.execute("UPDATE clinical.encounter_locations SET care_space_id = %s, is_bed_assignment = false WHERE id = %s", (BED[5], lid))

    def test_103_closing_a_stay_does_not_reclassify_it(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            lid = w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(90))
            w.conn.execute("SET LOCAL session_replication_role = replica")                # simula: el espacio dejó de ser cama después
            w.conn.execute("UPDATE practice.care_spaces SET form_concept_id = %s WHERE id = %s", (C["FORM_ROOM"], BED[3]))
            w.conn.execute("SET LOCAL session_replication_role = origin")
            w.conn.execute("UPDATE clinical.encounter_locations SET period_end = %s, location_status_concept_id = %s WHERE id = %s",
                           (day(95), C["COMPLETED"], lid))
            assert w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (lid,)) is True

    def test_104_a_nonexistent_space_fails_closed(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            for flag in (True, False):
                with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                    with w.conn.transaction():
                        w.loc(w.conn, ENC[3], str(uuid.uuid4()), "ACTIVE", day(90), bed=flag)
                assert "no se puede derivar si es una cama" in str(ei.value)             # lo dice el trigger, no una FK posterior

    def test_105_it_works_under_rls_as_the_app_role_and_other_tenants_spaces_still_fail(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            as_app(T1)
            assert w.count("practice.care_spaces") >= 7                                   # sanity: el rol ve sus espacios
            lid = w.loc(w.conn, ENC[3], BED[3], "ACTIVE", day(90), bed=False)             # sin tenant_id ni bandera: los pone la base
            assert w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (lid,)) is True
            assert w.one("SELECT tenant_id FROM clinical.encounter_locations WHERE id = %s", (lid,)) == uuid.UUID(T1)
            # el espacio del tenant 2 no se ve con RLS, pero la derivación no falla por eso: lo rechaza la FK compuesta
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    w.loc(w.conn, ENC[3], BX, "ACTIVE", day(95), bed=False)
            assert ei.value.diag.constraint_name == "fk_encounter_locations_tenant_space"

    def test_106_trigger_order_fills_the_tenant_before_deriving(self, world: World, patched: World) -> None:
        names = [r[0] for r in world.all("SELECT tgname FROM pg_trigger WHERE tgrelid = 'clinical.encounter_locations'::regclass "
                                         "AND NOT tgisinternal AND (tgtype & 4) = 4 AND (tgtype & 2) = 2 ORDER BY tgname")]
        assert names.index("trg_encounter_locations_fill_tenant") < names.index("trg_encounter_locations_set_bed_flag"), names

    def test_107_reapplying_the_patch_repairs_legacy_false_flags_or_aborts_on_overlap(self, world: World, patched: World) -> None:
        w = world
        trg = "trg_encounter_locations_set_bed_flag"
        w.conn.execute(f"ALTER TABLE clinical.encounter_locations DISABLE TRIGGER {trg}")
        try:
            a = w.loc(w.conn, ENC[3], BED[6], "ACTIVE", day(100), bed=False)             # filas que un escritor antiguo/bypass dejó en false
            assert w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (a,)) is False
            res = w.apply_patch()
            assert res.returncode == 0, res.stderr
            assert w.one("SELECT is_bed_assignment FROM clinical.encounter_locations WHERE id = %s", (a,)) is True   # corregida a true
            assert w.one("SELECT tgenabled FROM pg_trigger WHERE tgname = %s", (trg,)) == "O"                       # y el trigger vuelve a estar activo
            w.conn.execute(f"ALTER TABLE clinical.encounter_locations DISABLE TRIGGER {trg}")
            w.loc(w.conn, ENC[4], BED[6], "ACTIVE", day(101), bed=False)                 # dos pacientes en la misma cama, ambos en false
            res = w.apply_patch()
            assert res.returncode != 0                                                    # al corregir la bandera chocan: aborta, sin dejar nada
            assert "ex_encounter_locations_bed_occupancy" in res.stderr
            assert w.count("clinical.encounter_locations", "care_space_id = %s AND NOT is_bed_assignment", (BED[6],)) == 1
        finally:
            w.conn.execute("DELETE FROM clinical.encounter_locations WHERE care_space_id = %s", (BED[6],))
            w.conn.execute(f"ALTER TABLE clinical.encounter_locations ENABLE TRIGGER {trg}")


class TestLClosedCensusRejectsInserts:
    """Hallazgo 2: INSERT de entradas en un día cerrado reescribe el censo «inmutable»."""

    def _closed_day(self, w: World, date: dt.date = dt.date(2026, 11, 3), **kw) -> str:
        d = _census_day(w, date=date, **kw)
        w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'sha256:abc', status_concept_id = %s WHERE id = %s",
                       (C["CENSUS_CLOSED"], d))
        return d

    def test_110_an_entry_cannot_be_inserted_into_a_closed_day(self, world: World, patched: World) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d = _census_day(w, date=dt.date(2026, 11, 3))
            _entry(w, d)                                                                  # abierto: se admite
            w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'h', status_concept_id = %s WHERE id = %s",
                           (C["CENSUS_CLOSED"], d))
            before = w.count("clinical.inpatient_census_entries", "census_day_id = %s", (d,))
            with pytest.raises(pgerr.RestrictViolation) as ei:
                with w.conn.transaction():
                    _entry(w, d, enc=ENC[4], patient=PAT[4])
            assert "cerrado y es inmutable" in str(ei.value)
            assert w.count("clinical.inpatient_census_entries", "census_day_id = %s", (d,)) == before

    def test_111_the_same_holds_for_the_app_role(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d = _census_day(w, date=dt.date(2026, 11, 4))
            w.conn.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'h' WHERE id = %s", (d,))
            as_app(T1)
            with pytest.raises(pgerr.RestrictViolation):
                with w.conn.transaction():
                    _entry(w, d)
            _adjust(w, d)                                                                 # el ajuste sigue siendo la vía sobre un día cerrado

    def test_112_a_missing_or_foreign_day_fails_closed_without_leaking_its_state(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:
                with w.conn.transaction():
                    _entry(w, str(uuid.uuid4()))                                          # día inexistente
            assert "no existe para este tenant" in str(ei.value)
            closed_t2 = self._closed_day(w, date=dt.date(2026, 11, 5), tenant=T2, site=S2, unit=UN2)
            as_app(T1)
            with pytest.raises(pgerr.ForeignKeyViolation) as ei:                          # día CERRADO de otro tenant: igual que inexistente
                with w.conn.transaction():
                    _entry(w, closed_t2)
            assert "no existe para este tenant" in str(ei.value)
            assert not isinstance(ei.value, pgerr.RestrictViolation)

    def test_113_the_trigger_is_not_hidden_by_rls_and_not_bypassable_with_a_null_tenant(self, world: World, patched: World, as_app) -> None:
        w = world
        with w.conn.transaction(force_rollback=True):
            d = _census_day(w, date=dt.date(2026, 11, 6))
            as_app(T2)                                                                    # contexto de otro tenant: ni siquiera ve el día
            assert w.count("clinical.inpatient_census_days") == 0
            with pytest.raises((pgerr.ForeignKeyViolation, pgerr.InsufficientPrivilege)):
                with w.conn.transaction():
                    _entry(w, d)

    def test_114_closing_waits_for_an_in_flight_entry_and_the_entry_wins_the_race_or_is_rejected(self, world: World, patched: World) -> None:
        w = world
        date = dt.date(2026, 11, 20)
        d = _census_day(w, date=date)
        a = psycopg.connect(_dsn(w.db), autocommit=False)
        out: dict = {}

        def closer() -> None:
            b = psycopg.connect(_dsn(w.db), autocommit=False)
            try:
                out["pid"] = b.info.backend_pid
                b.execute("UPDATE clinical.inpatient_census_days SET closed_at = now(), content_hash = 'h', status_concept_id = %s WHERE id = %s",
                          (C["CENSUS_CLOSED"], d))
                b.commit()
                out["closed"] = True
            finally:
                b.close()

        try:
            eid = str(uuid.uuid4())
            a.execute("INSERT INTO clinical.inpatient_census_entries (id, tenant_id, census_day_id, encounter_id, patient_profile_id, care_space_id, "
                      "bed_category_concept_id, movement_concept_id, occurred_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, now())",
                      (eid, T1, d, ENC[3], PAT[3], BED[3], C["BED_CAT_ICU"], C["CEN_PRESENT"]))          # A: entrada sin confirmar
            th = threading.Thread(target=closer)
            th.start()
            deadline = time.time() + 10
            waiting = False
            while time.time() < deadline and not waiting:
                time.sleep(0.2)
                if "pid" in out:
                    waiting = bool(w.one("SELECT count(*) FROM pg_stat_activity WHERE pid = %s AND wait_event_type = 'Lock'", (out["pid"],)))
            assert waiting, "el cierre no esperó a la entrada en vuelo"
            a.commit()
            th.join(10)
            assert out.get("closed")
            assert w.count("clinical.inpatient_census_entries", "id = %s", (eid,)) == 1
            with pytest.raises(pgerr.RestrictViolation):                                          # y ahora, ya cerrado, no entra otra
                _entry(w, d, enc=ENC[4], patient=PAT[4])
        finally:
            a.close()
            _owner_conn_cleanup(w, "DELETE FROM clinical.inpatient_census_entries WHERE census_day_id = %s", (d,))
            _owner_conn_cleanup(w, "DELETE FROM clinical.inpatient_census_days WHERE id = %s", (d,))
