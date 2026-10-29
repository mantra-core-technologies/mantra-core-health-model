#!/usr/bin/env python3
"""Contrato y pruebas del patch F1c · Plano (v4.2.68).

Dos capas, como el resto de salud-db/tests:

* ``StaticContractTests`` lee el patch y los .puml: corre siempre, sin base.
* ``LivePlanoTests`` ejecuta el patch contra un Postgres REAL (psql) y prueba solapes,
  polígonos inválidos, contención, tenant, RLS, versión de layout e historia solo-inserción.
  Se salta —diciendo por qué— si no hay base. Para correrla:

    docker exec … psql -U mantra -d postgres -c "CREATE DATABASE m_plano TEMPLATE alovida"
    PLANO_TEST_DSN="host=localhost port=5433 user=mantra dbname=m_plano" \\
    PGPASSWORD=local_dev_only python -m pytest salud-db/tests/test_infra_f1c_plano.py

  La base TIENE que ser una copia desechable (nunca `alovida`): las pruebas crean y no
  borran filas, y la historia es solo inserción. La base debe tener F1 + F1b aplicados.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import unittest
import uuid
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PATCH = REPO / "SQL" / "patches" / "2026-10-29_infraestructura_f1c_plano.sql"
PUML14 = REPO / "Mantra Core Health Context" / "modules" / "diagram_14_practice.puml"
PUML10 = REPO / "Mantra Core Health Context" / "modules" / "diagram_10_audit.puml"
SEED = REPO / "salud-db" / "demo" / "04-plano-hospital-ejemplo.sql"

DSN = os.environ.get("PLANO_TEST_DSN", "host=localhost port=5433 user=mantra dbname=m_plano")


# --------------------------------------------------------------------------- estática
class StaticContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sql = PATCH.read_text(encoding="utf-8")
        cls.puml14 = PUML14.read_text(encoding="utf-8")
        cls.puml10 = PUML10.read_text(encoding="utf-8")

    def test_patch_is_one_transaction_and_idempotent_by_construction(self) -> None:
        self.assertEqual(len(re.findall(r"^BEGIN;", self.sql, re.M)), 1)
        self.assertEqual(len(re.findall(r"^COMMIT;", self.sql, re.M)), 1)
        for table in ("floor_plans", "space_placements", "plan_elements"):
            self.assertIn(f'CREATE TABLE IF NOT EXISTS "practice"."{table}"', self.sql)
            self.assertIn(f'CREATE TABLE IF NOT EXISTS "audit"."{table}_history"', self.sql)
        # nada de DDL suelto que falle al repetir: cada CREATE INDEX lleva IF NOT EXISTS
        for line in re.findall(r"^CREATE (?:UNIQUE )?INDEX .*$", self.sql, re.M):
            self.assertIn("IF NOT EXISTS", line, line)

    def test_every_new_table_has_tenant_rls_forced(self) -> None:
        for table in ("practice.floor_plans", "practice.space_placements", "practice.plan_elements",
                      "audit.floor_plans_history", "audit.space_placements_history",
                      "audit.plan_elements_history"):
            self.assertIn(f"'{table}'", self.sql)
        for needle in ("ENABLE ROW LEVEL SECURITY", "FORCE ROW LEVEL SECURITY", "CREATE POLICY tenant_isolation",
                       "current_setting('app.current_tenant_id', true)", "WITH CHECK"):
            self.assertIn(needle, self.sql)

    def test_cross_tenant_references_use_composite_fks(self) -> None:
        for name in ("fk_floor_plans_tenant_site", "fk_floor_plans_tenant_anchor",
                     "fk_space_placements_tenant_plan", "fk_space_placements_tenant_space",
                     "fk_plan_elements_tenant_plan", "fk_plan_elements_tenant_host",
                     "fk_plan_elements_tenant_space_a", "fk_plan_elements_tenant_space_b"):
            self.assertIn(f"'{name}'", self.sql)
        self.assertIn('FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")', self.sql)

    def test_overlap_is_a_database_constraint_not_an_api_promise(self) -> None:
        self.assertIn("ex_space_placements_no_overlap", self.sql)
        self.assertIn('EXCLUDE USING gist ("floor_plan_id" WITH =, "sibling_group_id" WITH =, "overlap_outline" WITH &&)', self.sql)
        self.assertIn("DEFERRABLE INITIALLY IMMEDIATE", self.sql)
        self.assertIn("CREATE EXTENSION IF NOT EXISTS btree_gist", self.sql)
        # precondición sobre filas previas, como el resto de los EXCLUDE del modelo
        self.assertRegex(self.sql, r"RAISE EXCEPTION 'F1c: % par\(es\) de espacios hermanos solapados")

    def test_history_is_insert_only_like_f1b(self) -> None:
        self.assertIn('GRANT UPDATE ("valid_to") ON %s TO mantra_app', self.sql)
        self.assertIn("REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app", self.sql)
        self.assertIn("structure_history_close_only", self.sql)
        self.assertIn("structure_history_fill_tenant", self.sql)

    def test_floor_plans_are_never_physically_deleted(self) -> None:
        self.assertIn("REVOKE DELETE, TRUNCATE ON %s FROM mantra_app", self.sql)
        self.assertIn("base_sin_delete text[] := ARRAY['practice.floor_plans']", self.sql)

    def test_no_norm_is_hardcoded(self) -> None:
        # la tolerancia de contacto y la de área son datos, no constantes de norma
        self.assertIn("contact_tolerance_m", self.sql)
        self.assertIn("infra.plan.area_tolerance_pct", self.sql)
        self.assertNotRegex(self.sql, r"\b(NTS|FGI|NOM-0|HBN|Ley 475)\b.*\d+\s*m")

    def test_generated_files_are_not_touched_by_this_change(self) -> None:
        # el integrador regenera estos; el agente del plano no los edita a mano
        report = (REPO / "SQL" / "_generation_report.md").read_text(encoding="utf-8")
        self.assertNotIn("floor_plans", report)

    def test_puml_declares_the_same_tables_and_columns(self) -> None:
        def has(pattern: str, text: str) -> bool:
            return re.search(pattern, text) is not None

        for ent in ("floor_plans", "space_placements", "plan_elements"):
            self.assertTrue(has(rf"(?m)^entity {ent} \{{", self.puml14), f"falta entity {ent} en diagram_14")
        for ent in ("floor_plans_history", "space_placements_history", "plan_elements_history"):
            self.assertTrue(has(rf"(?m)^entity {ent} <<HISTORY>> \{{", self.puml10), f"falta entity {ent} en diagram_10")
        # las columnas geométricas nativas no entran al .puml (gen_ddl las omitiría): se explican en comentario
        for col in ("outline", "overlap_outline", "bbox"):
            self.assertTrue(has(rf"(?m)^'.*{col}", self.puml14), f"falta el comentario sobre {col}")
        for col in ("layout_version", "contact_tolerance_m", "grid_size_m", "background_scale_m_per_px",
                    "sibling_group_id", "vertices", "host_element_id", "vertical_link_code"):
            self.assertIn(col, self.puml14)
        # cada columna del patch existe en el .puml (salvo las geométricas nativas, que solo viven en el patch)
        for table in ("floor_plans", "space_placements", "plan_elements"):
            block = re.search(rf'CREATE TABLE IF NOT EXISTS "practice"\."{table}" \((.*?)\n\);', self.sql, re.S).group(1)
            cols = re.findall(r'^\s+"([a-z_0-9]+)" ', block, re.M)
            ent = re.search(rf"(?ms)^entity {table} \{{(.*?)^\}}", self.puml14).group(1)
            for col in cols:
                self.assertTrue(has(rf"(?m)^\s*\*?\s*{col} :", ent), f"{table}.{col} falta en el .puml")

    def test_seed_is_idempotent_and_never_hardcodes_concept_uuids(self) -> None:
        seed = SEED.read_text(encoding="utf-8")
        self.assertIn("ON CONFLICT", seed)
        self.assertNotRegex(seed, r"'[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}'::uuid\s*--\s*practice:")
        self.assertIn("catalog_concepts", seed)


# --------------------------------------------------------------------------- viva
def _psql(sql: str, *, dsn: str = DSN, role: str | None = None, tenant: str | None = None,
          system: bool = False) -> tuple[int, str, str]:
    pre = []
    if role:
        pre.append(f"SET ROLE {role};")
    if tenant:
        pre.append(f"SET app.current_tenant_id = '{tenant}';")
    if system:
        pre.append("SET app.system_context = 'true';")
    proc = subprocess.run(
        ["psql", dsn, "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1", "-f", "-"],
        input="\n".join(pre) + "\n" + sql, capture_output=True, text=True, timeout=120,
    )
    return proc.returncode, proc.stdout.strip(), proc.stderr.strip()


def _db_available() -> str | None:
    if shutil.which("psql") is None:
        return "psql no está instalado"
    rc, out, err = _psql("select to_regclass('practice.ux_care_spaces_tenant_id_id') is not null "
                         "and to_regprocedure('audit.structure_history_close_only()') is not null;")
    if rc != 0:
        return f"sin base de pruebas ({err.splitlines()[-1] if err else 'psql falló'})"
    if out != "t":
        return "la base no tiene F1 + F1b aplicados"
    if "dbname=alovida" in DSN:
        return "no se prueba contra `alovida`: usar una copia desechable"
    return None


def rect_sql(tenant: str, plan: str, space: str, cx: float, cy: float, w: float, d: float, rot: float = 0.0,
             pid: str | None = None) -> str:
    return (f"INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, "
            f"center_x_m, center_y_m, width_m, depth_m, rotation_deg, vertices) VALUES "
            f"('{pid or uuid.uuid4()}', '{tenant}', '{plan}', '{space}', 'RECT', {cx}, {cy}, {w}, {d}, {rot}, '[]'::jsonb);")


def poly_sql(tenant: str, plan: str, space: str, pts: list[tuple[float, float]], pid: str | None = None) -> str:
    verts = "[" + ",".join(f"[{x},{y}]" for x, y in pts) + "]"
    return (f"INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, vertices) "
            f"VALUES ('{pid or uuid.uuid4()}', '{tenant}', '{plan}', '{space}', 'POLYGON', '{verts}'::jsonb);")


def wall_sql(tenant: str, plan: str, pts: list[tuple[float, float]], eid: str | None = None, thickness: float = 0.2) -> str:
    verts = "[" + ",".join(f"[{x},{y}]" for x, y in pts) + "]"
    return (f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, thickness_m) "
            f"VALUES ('{eid or uuid.uuid4()}', '{tenant}', '{plan}', 'WALL', '{verts}'::jsonb, {thickness});")


@unittest.skipIf(_db_available() is not None, f"base de pruebas no disponible: {_db_available()}")
class LivePlanoTests(unittest.TestCase):
    """Cada prueba corre en su propia transacción cuando necesita deshacer; las que prueban el COMMIT
    (restricciones diferidas) usan filas propias con UUID nuevos, así que se pueden repetir."""

    # ---- fixture: dos tenants, cada uno con sede, ala (LEVEL), sala (WARD), habitaciones y camas
    @classmethod
    def setUpClass(cls) -> None:
        u = lambda: str(uuid.uuid4())  # noqa: E731
        cls.ta, cls.tb = u(), u()
        cls.fx: dict[str, str] = {}
        lines = ["SET app.system_context = 'true';", "SET session_replication_role = replica;"]
        for tag, t in (("a", cls.ta), ("b", cls.tb)):
            ids = {k: u() for k in ("practice", "site", "site2", "level", "ward", "roomA", "roomB", "bed1", "bed2", "extra", "plan", "plan2")}
            for k, v in ids.items():
                cls.fx[f"{tag}_{k}"] = v
            c = u()  # concepto placeholder (las FK a conceptos se saltan con replica)
            lines += [
                f"INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, legal_entity_type_concept_id, "
                f"status_concept_id, verification_status_concept_id, created_at, updated_at) VALUES "
                f"('{t}', 'T-{t[:8]}', '{c}', 'Tenant {tag}', '{c}', '{c}', '{c}', now(), now());",
                f"INSERT INTO practice.practices (id, tenant_id, code, name, type_concept_id, admin_user_id, status_concept_id, created_at, updated_at) "
                f"VALUES ('{ids['practice']}', '{t}', 'P-{ids['practice'][:8]}', 'Práctica {tag}', '{c}', '{u()}', '{c}', now(), now());",
            ]
            for s in ("site", "site2"):
                lines.append(
                    f"INSERT INTO practice.practice_sites (id, practice_id, code, name, site_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
                    f"VALUES ('{ids[s]}', '{ids['practice']}', 'S-{ids[s][:8]}', 'Sede', '{c}', '{c}', now(), now(), '{t}');")

            def space(key: str, parent: str | None, site: str = "site") -> None:
                lines.append(
                    f"INSERT INTO practice.care_spaces (id, practice_site_id, parent_space_id, code, name, space_type_concept_id, "
                    f"status_concept_id, created_at, updated_at, tenant_id) VALUES ('{ids[key]}', '{ids[site]}', "
                    f"{('NULL' if parent is None else repr(ids[parent]))}, 'C-{ids[key][:8]}', 'Espacio {key}', '{c}', '{c}', now(), now(), '{t}');")

            space("level", None)
            space("ward", "level")
            space("roomA", "ward")
            space("roomB", "ward")
            space("bed1", "roomA")
            space("bed2", "roomA")
            space("extra", "level")
            lines.append(
                f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, "
                f"created_at, updated_at) VALUES ('{ids['plan']}', '{t}', '{ids['site']}', '{ids['level']}', 'PB-{ids['plan'][:6]}', 'Planta baja', 40, 20, now(), now());")
            # segundo lienzo (sin ancla = campus) del mismo tenant, para probar pertenencia al ancla
            lines.append(
                f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, "
                f"created_at, updated_at) VALUES ('{ids['plan2']}', '{t}', '{ids['site']}', NULL, 'CP-{ids['plan2'][:6]}', 'Campus', 100, 80, now(), now());")
        lines.append("RESET session_replication_role;")
        rc, out, err = _psql("\n".join(lines))
        if rc != 0:
            raise RuntimeError(f"fixture falló: {err}")

    # ---- utilidades
    def f(self, key: str, tag: str = "a") -> str:
        return self.fx[f"{tag}_{key}"]

    def ok(self, sql: str, **kw) -> str:
        rc, out, err = _psql(sql, **kw)
        self.assertEqual(rc, 0, f"se esperaba éxito y falló: {err}\n{sql}")
        return out

    def fails(self, sql: str, needle: str, **kw) -> str:
        rc, out, err = _psql(sql, **kw)
        self.assertNotEqual(rc, 0, f"se esperaba error ({needle}) y no falló:\n{sql}")
        self.assertIn(needle, err, err)
        return err

    def tx(self, *stmts: str) -> str:
        return "SET app.system_context='true';\nBEGIN;\n" + "\n".join(stmts) + "\nCOMMIT;"

    def clean_plan(self, tag: str = "a") -> None:
        """Vacía el lienzo de planta baja del tenant (diferidos incluidos) para que cada prueba parta de cero."""
        t = self.ta if tag == "a" else self.tb
        self.ok("SET app.system_context='true';\nBEGIN;\n"
                f"DELETE FROM practice.plan_elements WHERE floor_plan_id IN ('{self.f('plan', tag)}','{self.f('plan2', tag)}') AND host_element_id IS NOT NULL;\n"
                f"DELETE FROM practice.plan_elements WHERE floor_plan_id IN ('{self.f('plan', tag)}','{self.f('plan2', tag)}');\n"
                f"DELETE FROM practice.space_placements WHERE tenant_id='{t}';\nCOMMIT;")

    # ---- 1. idempotencia y aplicación
    def _fingerprint(self) -> str:
        return self.ok("""
            SELECT md5(string_agg(x, '|' ORDER BY x)) FROM (
              SELECT ('col:' || table_schema || '.' || table_name || '.' || column_name || ':' || data_type || ':' || is_nullable || ':' || coalesce(column_default,'')) AS x
                FROM information_schema.columns WHERE table_schema IN ('practice','audit')
                 AND table_name IN ('floor_plans','space_placements','plan_elements','floor_plans_history','space_placements_history','plan_elements_history')
              UNION ALL SELECT 'con:' || conrelid::regclass || ':' || conname || ':' || pg_get_constraintdef(oid) FROM pg_constraint
                 WHERE conrelid::regclass::text ~ '(floor_plans|space_placements|plan_elements)'
              UNION ALL SELECT 'idx:' || indexdef FROM pg_indexes WHERE tablename ~ '(floor_plans|space_placements|plan_elements)'
              UNION ALL SELECT 'trg:' || pg_get_triggerdef(t.oid) FROM pg_trigger t WHERE NOT tgisinternal
                 AND (tgrelid::regclass::text ~ '(floor_plans|space_placements|plan_elements)' OR tgname = 'trg_care_spaces_revalidate_placements')
              UNION ALL SELECT 'pol:' || tablename || ':' || policyname || ':' || coalesce(qual,'') || coalesce(with_check,'') FROM pg_policies
                 WHERE tablename ~ '(floor_plans|space_placements|plan_elements)'
              UNION ALL SELECT 'fn:' || p.oid::regprocedure || md5(p.prosrc) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
                 WHERE n.nspname='practice' AND p.proname ~ '^(plan_|space_placements_|floor_plans_|care_spaces_revalidate)'
              UNION ALL SELECT 'grant:' || table_name || ':' || grantee || ':' || privilege_type FROM information_schema.role_table_grants
                 WHERE grantee='mantra_app' AND table_name ~ '(floor_plans|space_placements|plan_elements)'
              UNION ALL SELECT 'view:' || md5(pg_get_viewdef('practice.v_floor_plan_spaces'::regclass))
            ) q;""")

    def test_01_patch_applies_twice_and_second_pass_changes_nothing(self) -> None:
        def apply() -> str:
            proc = subprocess.run(["psql", DSN, "-X", "-q", "-v", "ON_ERROR_STOP=1", "-f", str(PATCH)],
                                  capture_output=True, text=True, timeout=300)
            self.assertEqual(proc.returncode, 0, proc.stderr)
            return proc.stderr
        first = apply()
        before = self._fingerprint()
        second = apply()
        after = self._fingerprint()
        self.assertEqual(before, after, "la segunda pasada cambió el esquema")
        self.assertIn("v4.2.68 aplicado", first)
        self.assertIn("v4.2.68 aplicado", second)

    # ---- 2. geometría derivada
    def test_02_rect_derives_vertices_area_bbox(self) -> None:
        self.clean_plan()
        pid = str(uuid.uuid4())
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("extra"), 10, 5, 4, 3, 0, pid)))
        row = self.ok(f"SELECT area_calc_m2, bbox::text, vertices::text FROM practice.space_placements WHERE id='{pid}'", system=True)
        self.assertTrue(row.startswith("12.000|(12,6.5),(8,3.5)"), row)
        # rotado 90°: ancho y fondo se intercambian en la caja envolvente
        pid2 = str(uuid.uuid4())
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 30, 10, 4, 3, 90, pid2)))
        bb = self.ok(f"SELECT bbox::text, area_calc_m2 FROM practice.space_placements WHERE id='{pid2}'", system=True)
        self.assertEqual(bb, "(31.5,12),(28.5,8)|12.000")

    def test_03_polygon_area_and_l_shape(self) -> None:
        self.clean_plan()
        pid = str(uuid.uuid4())
        self.ok(self.tx(poly_sql(self.ta, self.f("plan"), self.f("ward"), [(0, 0), (8, 0), (8, 2), (3, 2), (3, 6), (0, 6)], pid)))
        self.assertEqual(self.ok(f"SELECT area_calc_m2 FROM practice.space_placements WHERE id='{pid}'", system=True), "28.000")

    # ---- 3. solapes (EXCLUDE) con tolerancia de contacto
    def test_04_sharing_a_wall_is_not_an_overlap_but_real_overlap_is(self) -> None:
        self.clean_plan()
        # dos locales hermanos que comparten la pared x=10 (se tocan) → permitido
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 5, 5, 10, 6),
                        rect_sql(self.ta, self.f("plan"), self.f("extra"), 15, 5, 10, 6)))
        # 0,5 m metidos en el vecino → ex_space_placements_no_overlap
        self.clean_plan()
        self.fails(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 5, 5, 10, 6),
                           rect_sql(self.ta, self.f("plan"), self.f("extra"), 14.5, 5, 10, 6)),
                   "ex_space_placements_no_overlap")

    def test_05_overlap_is_exact_not_bounding_box(self) -> None:
        self.clean_plan()
        # L: la caja envolvente cubre (0..8, 0..6) pero el hueco (3..8, 2..6) está libre; el hermano cabe en el hueco
        self.ok(self.tx(
            poly_sql(self.ta, self.f("plan"), self.f("ward"), [(0, 0), (8, 0), (8, 2), (3, 2), (3, 6), (0, 6)]),
            rect_sql(self.ta, self.f("plan"), self.f("extra"), 5.5, 4.0, 4, 3)))
        self.clean_plan()
        # y si entra en la L (se mete en el brazo horizontal) → solape
        self.fails(self.tx(
            poly_sql(self.ta, self.f("plan"), self.f("ward"), [(0, 0), (8, 0), (8, 2), (3, 2), (3, 6), (0, 6)]),
            rect_sql(self.ta, self.f("plan"), self.f("extra"), 5.5, 1.5, 4, 2)), "ex_space_placements_no_overlap")

    def test_06_rotated_neighbours(self) -> None:
        self.clean_plan()
        # un cuadrado girado 45° cuyas esquinas entran al vecino
        self.fails(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 6, 6, 6, 6),
                           rect_sql(self.ta, self.f("plan"), self.f("extra"), 12, 6, 6, 6, 45)),
                   "ex_space_placements_no_overlap")

    def test_07_swap_two_rooms_in_one_transaction_needs_deferred_exclude(self) -> None:
        self.clean_plan()
        a, b = str(uuid.uuid4()), str(uuid.uuid4())
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 5, 5, 6, 4, 0, a),
                        rect_sql(self.ta, self.f("plan"), self.f("extra"), 12, 5, 6, 4, 0, b)))
        # mover A encima de B antes de mover B: inmediato falla, diferido pasa si al final no hay solape
        swap = (f"UPDATE practice.space_placements SET center_x_m = 12 WHERE id='{a}';\n"
                f"UPDATE practice.space_placements SET center_x_m = 5 WHERE id='{b}';")
        self.fails(self.tx(swap), "ex_space_placements_no_overlap")
        self.ok("SET app.system_context='true';\nBEGIN;\nSET CONSTRAINTS practice.ex_space_placements_no_overlap DEFERRED;\n" + swap + "\nCOMMIT;")
        self.assertEqual(self.ok(f"SELECT center_x_m FROM practice.space_placements WHERE id='{a}'", system=True), "12.000")

    # ---- 4. geometría inválida
    def test_08_invalid_polygons_are_rejected(self) -> None:
        self.clean_plan()
        t, p, s = self.ta, self.f("plan"), self.f("ward")
        cases = {
            "corbata (se cruza)": [(0, 0), (4, 4), (4, 0), (0, 4)],
            "área cero (colineal)": [(0, 0), (2, 0), (4, 0)],
            "vértice repetido": [(0, 0), (0, 0), (4, 0), (4, 4)],
            "arista que toca otra": [(0, 0), (6, 0), (6, 6), (3, 0), (0, 6)],
            "dos vértices": [(0, 0), (4, 0)],
        }
        for name, pts in cases.items():
            with self.subTest(name):
                self.fails(self.tx(poly_sql(t, p, s, pts)), "PLAN_GEOMETRY_INVALID")
        with self.subTest("65 vértices"):
            pts = [(i * 0.1, (i % 2) * 0.1) for i in range(65)]
            self.fails(self.tx(poly_sql(t, p, s, pts)), "PLAN_GEOMETRY_INVALID")

    def test_09_rect_parameters_are_checked(self) -> None:
        t, p, s = self.ta, self.f("plan"), self.f("ward")
        self.fails(self.tx(rect_sql(t, p, s, 5, 5, 0, 3)), "PLAN_GEOMETRY_INVALID")  # ancho 0: área 0
        self.fails(self.tx(rect_sql(t, p, s, 5, 5, 0.01, 3)), "ck_space_placements_rect_size")  # menor al mínimo de 5 cm
        self.fails(self.tx(rect_sql(t, p, s, 5, 5, 3, 3, 360)), "ck_space_placements_rotation")
        self.fails(self.tx(f"INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, vertices) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', '{s}', 'RECT', '[]');"), "PLAN_GEOMETRY_INVALID")  # RECT sin parámetros
        self.fails(self.tx(f"INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, vertices, center_x_m) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', '{s}', 'POLYGON', '[[0,0],[1,0],[1,1]]', 3);"), "ck_space_placements_shape_params")
        self.fails(self.tx(f"INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, vertices) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', '{s}', 'CIRCLE', '[[0,0],[1,0],[1,1]]');"), "ck_space_placements_shape_kind")

    def test_10_out_of_bounds(self) -> None:
        self.clean_plan()
        self.fails(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 39, 10, 4, 3)), "PLAN_OUT_OF_BOUNDS")  # lienzo 40 × 20
        self.fails(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 2, -0.5, 4, 3)), "PLAN_OUT_OF_BOUNDS")
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 2, 1.5, 4, 3)))  # a ras del borde: dentro

    # ---- 5. árbol en el plano: padre ubicado, hijo dentro del padre (diferido al COMMIT)
    def test_11_child_must_fit_inside_parent_at_commit(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        ward, room = self.f("ward"), self.f("roomA")
        # orden inverso (hijo antes que padre) funciona: la restricción mira el estado final
        self.ok(self.tx(rect_sql(t, p, room, 5, 5, 4, 4), rect_sql(t, p, ward, 8, 6, 16, 10)))
        self.clean_plan()
        # a ras de la pared del padre: permitido
        self.ok(self.tx(rect_sql(t, p, ward, 10, 6, 20, 10), rect_sql(t, p, room, 3, 6, 6, 10)))
        self.clean_plan()
        # se sale 3 m por la derecha → PLAN_CHILD_OUTSIDE_PARENT
        self.fails(self.tx(rect_sql(t, p, ward, 10, 6, 20, 10), rect_sql(t, p, room, 19, 6, 6, 10)), "PLAN_CHILD_OUTSIDE_PARENT")

    def test_12_parent_must_be_placed_on_the_same_canvas(self) -> None:
        self.clean_plan()
        # roomA cuelga de la sala (ward) y la sala no está ubicada: no se puede
        self.fails(self.tx(rect_sql(self.ta, self.f("plan"), self.f("roomA"), 5, 5, 4, 4)), "PLAN_PARENT_NOT_PLACED")
        # la sala sí puede (su padre es el ancla del lienzo)
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 10, 6, 20, 10)))
        # una raíz del árbol no entra a un lienzo anclado a un espacio
        self.fails(self.tx(rect_sql(self.ta, self.f("plan"), self.f("level"), 10, 6, 5, 5)), "PLAN_PARENT_NOT_PLACED")
        # en el lienzo de campus (sin ancla) entran las raíces y no sus hijos sueltos
        self.ok(self.tx(rect_sql(self.ta, self.f("plan2"), self.f("level"), 50, 40, 30, 20)))
        self.fails(self.tx(rect_sql(self.ta, self.f("plan2"), self.f("roomA"), 50, 40, 3, 3)), "PLAN_PARENT_NOT_PLACED")
        # `extra` sí: su padre (level) está ubicado en el campus y la contiene
        self.ok(self.tx(rect_sql(self.ta, self.f("plan2"), self.f("extra"), 50, 40, 3, 3)))

    def test_13_moving_a_parent_revalidates_children(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        w, r = str(uuid.uuid4()), str(uuid.uuid4())
        self.ok(self.tx(rect_sql(t, p, self.f("ward"), 10, 6, 20, 10, 0, w), rect_sql(t, p, self.f("roomA"), 4, 6, 6, 10, 0, r)))
        self.fails(self.tx(f"UPDATE practice.space_placements SET center_x_m = 30 WHERE id='{w}';"), "PLAN_CHILD_OUTSIDE_PARENT")
        # moviendo padre e hijo en la misma transacción sí
        self.ok(self.tx(f"UPDATE practice.space_placements SET center_x_m = 30 WHERE id='{w}';",
                        f"UPDATE practice.space_placements SET center_x_m = 24 WHERE id='{r}';"))

    def test_14_cannot_unplace_a_parent_with_placed_children(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        w, r = str(uuid.uuid4()), str(uuid.uuid4())
        self.ok(self.tx(rect_sql(t, p, self.f("ward"), 10, 6, 20, 10, 0, w), rect_sql(t, p, self.f("roomA"), 4, 6, 6, 10, 0, r)))
        self.fails(self.tx(f"DELETE FROM practice.space_placements WHERE id='{w}';"), "PLAN_HAS_PLACED_CHILDREN")
        self.ok(self.tx(f"DELETE FROM practice.space_placements WHERE id IN ('{w}','{r}');"))

    def test_15_tree_move_that_breaks_the_drawing_is_rejected(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        self.ok(self.tx(rect_sql(t, p, self.f("ward"), 10, 6, 20, 10), rect_sql(t, p, self.f("roomA"), 4, 6, 6, 10)))
        # mover roomA bajo `extra` (que no está ubicado en el lienzo) deja al hijo sin padre dibujado
        self.fails(self.tx(f"UPDATE practice.care_spaces SET parent_space_id='{self.f('extra')}' WHERE id='{self.f('roomA')}';"),
                   "PLAN_PARENT_NOT_PLACED")
        self.assertEqual(self.ok(f"SELECT parent_space_id::text FROM practice.care_spaces WHERE id='{self.f('roomA')}'", system=True),
                         self.f("ward"))

    def test_16_one_place_per_space(self) -> None:
        self.clean_plan()
        t = self.ta
        self.ok(self.tx(rect_sql(t, self.f("plan"), self.f("ward"), 10, 6, 20, 10)))
        self.fails(self.tx(rect_sql(t, self.f("plan2"), self.f("ward"), 10, 6, 20, 10)), "ux_space_placements_care_space")

    # ---- 6. tenant y sede
    def test_17_cross_tenant_references_are_rejected_by_the_database(self) -> None:
        self.clean_plan()
        # espacio del tenant B en un lienzo del tenant A
        self.fails(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward", "b"), 10, 6, 5, 5)), "PLAN_SPACE_NOT_FOUND")
        # lienzo del tenant B desde una fila del tenant A
        self.fails(self.tx(rect_sql(self.ta, self.f("plan", "b"), self.f("ward"), 10, 6, 5, 5)), "PLAN_NOT_FOUND")
        # fila del tenant B apuntando al lienzo y espacio del A: la FK compuesta lo frena
        self.fails(self.tx(rect_sql(self.tb, self.f("plan"), self.f("ward"), 10, 6, 5, 5)), "PLAN_NOT_FOUND")
        # lienzo anclado a un espacio de otro tenant
        self.fails(self.tx(
            f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, created_at, updated_at) "
            f"VALUES (gen_random_uuid(), '{self.ta}', '{self.f('site')}', '{self.f('ward', 'b')}', 'X1', 'x', 10, 10, now(), now());"),
            "fk_floor_plans_tenant_anchor")
        # sede de otro tenant
        self.fails(self.tx(
            f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, created_at, updated_at) "
            f"VALUES (gen_random_uuid(), '{self.ta}', '{self.f('site', 'b')}', '{self.f('ward')}', 'X2', 'x', 10, 10, now(), now());"),
            "fk_floor_plans_tenant_site")
        # muro del tenant A como anfitrión de una puerta del tenant B
        wid = str(uuid.uuid4())
        self.ok(self.tx(wall_sql(self.ta, self.f("plan"), [(0, 0), (10, 0)], wid)))
        self.fails(self.tx(
            f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, host_element_id, offset_m, width_m) "
            f"VALUES (gen_random_uuid(), '{self.tb}', '{self.f('plan', 'b')}', 'DOOR', '{wid}', 1, 1);"), "PLAN_HOST_NOT_WALL")
        # y aunque el trigger no estuviera, la FK compuesta (tenant_id, host_element_id) lo frena en la base
        self.fails("SET app.system_context='true';\nBEGIN;\nALTER TABLE practice.plan_elements DISABLE TRIGGER trg_plan_elements_derive;\n"
                   f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, host_element_id, offset_m, width_m) "
                   f"VALUES (gen_random_uuid(), '{self.tb}', '{self.f('plan', 'b')}', 'DOOR', '{wid}', 1, 1);\nCOMMIT;",
                   "fk_plan_elements_tenant_host")

    def test_18_space_of_another_site_is_rejected(self) -> None:
        self.clean_plan()
        sid = str(uuid.uuid4())
        self.ok("SET app.system_context='true';\nSET session_replication_role = replica;\n"
                f"INSERT INTO practice.care_spaces (id, practice_site_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
                f"VALUES ('{sid}', '{self.f('site2')}', 'OTRA-{sid[:6]}', 'Otra sede', '{sid}', '{sid}', now(), now(), '{self.ta}');")
        self.fails(self.tx(rect_sql(self.ta, self.f("plan2"), sid, 10, 6, 5, 5)), "PLAN_SPACE_OTHER_SITE")

    # ---- 7. RLS, privilegios e historia
    def test_19_rls_isolates_tenants(self) -> None:
        self.clean_plan("a")
        self.clean_plan("b")
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 10, 6, 20, 10),
                        rect_sql(self.tb, self.f("plan", "b"), self.f("ward", "b"), 10, 6, 20, 10)))
        a = self.ok("SELECT count(*) FROM practice.space_placements", role="mantra_app", tenant=self.ta)
        self.assertEqual(a, "1")
        self.assertEqual(self.ok(f"SELECT count(*) FROM practice.floor_plans WHERE tenant_id='{self.tb}'", role="mantra_app", tenant=self.ta), "0")
        self.assertEqual(self.ok("SELECT count(*) FROM practice.floor_plans", role="mantra_app"), "0")  # sin tenant: nada
        # escribir como A una fila de B: la política WITH CHECK lo niega
        self.fails(f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, created_at, updated_at) "
                   f"VALUES (gen_random_uuid(), '{self.tb}', '{self.f('site', 'b')}', '{self.f('level', 'b')}', 'RLS-X', 'x', 10, 10, now(), now());",
                   "row-level security", role="mantra_app", tenant=self.ta)
        # y sin contexto de tenant, ni siquiera una fila propia entra
        self.fails(f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, created_at, updated_at) "
                   f"VALUES (gen_random_uuid(), '{self.ta}', '{self.f('site')}', '{self.f('level')}', 'RLS-Y', 'y', 10, 10, now(), now());",
                   "row-level security", role="mantra_app")
        # ... y el contexto de sistema ve todo
        self.assertEqual(self.ok(f"SELECT count(*) FROM practice.space_placements WHERE tenant_id IN ('{self.ta}','{self.tb}')", system=True), "2")
        # la vista de lectura hereda el RLS del invocador (security_invoker)
        self.assertEqual(self.ok("SELECT count(*) FROM practice.v_floor_plan_spaces", role="mantra_app", tenant=self.ta), "1")

    def test_20_privileges_floor_plans_not_deletable_history_insert_only(self) -> None:
        self.fails(f"DELETE FROM practice.floor_plans WHERE id='{self.f('plan')}';", "permission denied", role="mantra_app", tenant=self.ta)
        h = str(uuid.uuid4())
        # un concepto real (las FK de la historia a conceptos se respetan; sólo el concepto nace con replica)
        self.ok("SET app.system_context='true';\nSET session_replication_role = replica;\n"
                f"INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, created_at, updated_at) "
                f"VALUES ('{h}', '{h}', 'TEST:F1C:{h[:8]}', 'f1c test', now(), now());")
        ins = (f"INSERT INTO audit.floor_plans_history (history_id, floor_plan_id, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at) "
               f"VALUES ('{h}', '{self.f('plan')}', 1, '{h}', now(), '{{\"k\":1}}', now());")
        # el tenant se completa solo desde la fila de origen
        self.ok(ins, system=True)
        self.assertEqual(self.ok(f"SELECT tenant_id::text FROM audit.floor_plans_history WHERE history_id='{h}'", system=True), self.ta)
        self.fails(f"UPDATE audit.floor_plans_history SET data_snapshot='{{}}' WHERE history_id='{h}';", "append-only", system=True)
        self.fails(f"DELETE FROM audit.floor_plans_history WHERE history_id='{h}';", "append-only", system=True)
        self.fails(f"DELETE FROM audit.floor_plans_history WHERE history_id='{h}';", "permission denied", role="mantra_app", tenant=self.ta)
        self.fails(f"UPDATE audit.floor_plans_history SET data_snapshot='{{}}' WHERE history_id='{h}';", "permission denied", role="mantra_app", tenant=self.ta)
        # otro tenant no la ve
        self.assertEqual(self.ok("SELECT count(*) FROM audit.floor_plans_history", role="mantra_app", tenant=self.tb), "0")
        self.ok(f"UPDATE audit.floor_plans_history SET valid_to = now() WHERE history_id='{h}';", role="mantra_app", tenant=self.ta)
        self.fails(f"UPDATE audit.floor_plans_history SET valid_to = now() WHERE history_id='{h}';", "append-only", system=True)  # una sola vez

    # ---- 8. versión del layout
    def test_21_layout_version_moves_once_per_transaction(self) -> None:
        self.clean_plan()
        p = self.f("plan")
        v0 = int(self.ok(f"SELECT layout_version FROM practice.floor_plans WHERE id='{p}'", system=True))
        self.ok(self.tx(rect_sql(self.ta, p, self.f("ward"), 10, 6, 20, 10), rect_sql(self.ta, p, self.f("extra"), 30, 6, 4, 4),
                        wall_sql(self.ta, p, [(0, 0), (10, 0)])))
        v1 = int(self.ok(f"SELECT layout_version FROM practice.floor_plans WHERE id='{p}'", system=True))
        self.assertEqual(v1, v0 + 1)
        # una transacción que falla no sube la versión
        self.fails(self.tx(rect_sql(self.ta, p, self.f("roomA"), 99, 6, 20, 10)), "PLAN_")
        self.assertEqual(int(self.ok(f"SELECT layout_version FROM practice.floor_plans WHERE id='{p}'", system=True)), v1)
        # el cliente no puede fijar la versión a mano
        self.ok(f"UPDATE practice.floor_plans SET layout_version = 999 WHERE id='{p}';", system=True)
        self.assertEqual(int(self.ok(f"SELECT layout_version FROM practice.floor_plans WHERE id='{p}'", system=True)), v1)
        # cambiar la grilla (metadato visible del lienzo) sube la versión una vez
        self.ok(f"UPDATE practice.floor_plans SET grid_size_m = 0.25 WHERE id='{p}';", system=True)
        self.assertEqual(int(self.ok(f"SELECT layout_version FROM practice.floor_plans WHERE id='{p}'", system=True)), v1 + 1)
        self.ok(f"UPDATE practice.floor_plans SET grid_size_m = 0.5 WHERE id='{p}';", system=True)

    # ---- 9. elementos
    def test_22_walls_and_hosted_openings(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        w, d = str(uuid.uuid4()), str(uuid.uuid4())
        door = lambda eid, off, wd: (  # noqa: E731
            f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, host_element_id, offset_m, width_m, swing, swing_side) "
            f"VALUES ('{eid}', '{t}', '{p}', 'DOOR', '{w}', {off}, {wd}, 'LEFT', 'A');")
        self.ok(self.tx(wall_sql(t, p, [(0, 0), (6, 0), (6, 4)], w), door(d, 2, 1.0)))
        self.assertEqual(self.ok(f"SELECT bbox IS NULL FROM practice.plan_elements WHERE id='{d}'", system=True), "t")
        self.assertEqual(self.ok(f"SELECT bbox::text FROM practice.plan_elements WHERE id='{w}'", system=True), "(6,4),(0,0)")
        # la puerta se pasa del largo del muro (10 m)
        self.fails(self.tx(door(str(uuid.uuid4()), 9.5, 1.0)), "PLAN_OPENING_OUTSIDE_WALL")
        # sobre algo que no es muro
        stairs = str(uuid.uuid4())
        self.ok(self.tx(f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices) VALUES "
                        f"('{stairs}', '{t}', '{p}', 'STAIRS', '[[30,2],[34,2],[34,6],[30,6]]');"))
        self.fails(self.tx(f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, host_element_id, offset_m, width_m) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', 'DOOR', '{stairs}', 0, 1);"), "PLAN_HOST_NOT_WALL")
        # acortar el muro con la puerta ya puesta
        self.fails(self.tx(f"UPDATE practice.plan_elements SET vertices = '[[0,0],[2,0]]' WHERE id='{w}';"), "PLAN_OPENING_OUTSIDE_WALL")
        # el muro no se puede borrar mientras tenga abertura (RESTRICT): la API quita primero la abertura
        self.fails(self.tx(f"DELETE FROM practice.plan_elements WHERE id='{w}';"), "fk_plan_elements_tenant_host")
        self.ok(self.tx(f"DELETE FROM practice.plan_elements WHERE id='{d}';", f"DELETE FROM practice.plan_elements WHERE id='{w}';"))

    def test_23_invalid_elements(self) -> None:
        t, p = self.ta, self.f("plan")
        self.fails(self.tx(wall_sql(t, p, [(0, 0)])), "ck_plan_elements_geometry_by_kind")  # un solo punto
        self.fails(self.tx(wall_sql(t, p, [(0, 0), (5, 0)], thickness=0.001)), "ck_plan_elements_dimensions")
        self.fails(self.tx(wall_sql(t, p, [(0, 0), (500, 0)])), "PLAN_OUT_OF_BOUNDS")
        self.fails(self.tx(f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, label) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', 'ANNOTATION', '[[1,1]]', NULL);"), "ck_plan_elements_geometry_by_kind")
        self.fails(self.tx(f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', 'CIRCULATION', '[[0,0],[4,4],[4,0],[0,4]]');"), "ck_plan_elements_geometry_by_kind")
        self.fails(self.tx(f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', 'DRAGON', '[[0,0],[4,0],[4,4]]');"), "violates check constraint")
        self.fails(self.tx(f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, swing) "
                           f"VALUES (gen_random_uuid(), '{t}', '{p}', 'ANNOTATION', '[[1,1]]', 'LEFT');"), "ck_plan_elements_")
        self.ok(self.tx(f"INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, label) "
                        f"VALUES (gen_random_uuid(), '{t}', '{p}', 'ANNOTATION', '[[1,1]]', 'N ↑');"))

    # ---- 10. lienzo
    def test_24_canvas_rules(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        self.ok(self.tx(rect_sql(t, p, self.f("ward"), 30, 10, 20, 10)))
        self.fails(f"UPDATE practice.floor_plans SET width_m = 35 WHERE id='{p}';", "PLAN_BOUNDS_EXCLUDE_CONTENT", system=True)
        self.ok(f"UPDATE practice.floor_plans SET width_m = 45 WHERE id='{p}';", system=True)
        self.ok(f"UPDATE practice.floor_plans SET width_m = 40 WHERE id='{p}';", system=True)
        self.fails(f"UPDATE practice.floor_plans SET anchor_space_id = NULL WHERE id='{p}';", "PLAN_ANCHOR_IMMUTABLE", system=True)
        self.fails(f"UPDATE practice.floor_plans SET practice_site_id = '{self.f('site2')}' WHERE id='{p}';", "PLAN_ANCHOR_IMMUTABLE", system=True)
        self.fails(f"UPDATE practice.floor_plans SET contact_tolerance_m = 0.5 WHERE id='{p}';", "ck_floor_plans_contact_tolerance", system=True)
        self.fails(f"UPDATE practice.floor_plans SET background_file_id = gen_random_uuid() WHERE id='{p}';", "ck_floor_plans_background", system=True)
        # un lienzo vigente por ancla
        self.fails(self.tx(f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, created_at, updated_at) "
                           f"VALUES (gen_random_uuid(), '{t}', '{self.f('site')}', '{self.f('level')}', 'DUP', 'dup', 10, 10, now(), now());"),
                   "ux_floor_plans_anchor_current")
        # el código es único por sede
        self.fails(self.tx(f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, created_at, updated_at) "
                           f"SELECT gen_random_uuid(), tenant_id, practice_site_id, '{self.f('ward')}', code, 'otro', 10, 10, now(), now() FROM practice.floor_plans WHERE id='{p}';"),
                   "ux_floor_plans_site_code")

    def test_25_contact_tolerance_is_data_and_recomputes_the_outline(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        self.ok(self.tx(rect_sql(t, p, self.f("ward"), 5, 5, 10, 6), rect_sql(t, p, self.f("extra"), 15, 5, 10, 6)))
        # tolerancia 0: dos locales que se tocan YA se solapan (contacto cuenta) → el UPDATE del lienzo falla
        self.fails(f"UPDATE practice.floor_plans SET contact_tolerance_m = 0 WHERE id='{p}';", "ex_space_placements_no_overlap", system=True)
        # con la tolerancia por defecto el contorno de contacto es menor que el contorno
        self.assertEqual(self.ok(f"SELECT bool_and(overlap_outline <@ outline) FROM practice.space_placements WHERE floor_plan_id='{p}'", system=True), "t")

    # ---- 11. consultas de apoyo
    def test_26_validate_unplaced_and_area_tolerance(self) -> None:
        self.clean_plan()
        t, p = self.ta, self.f("plan")
        self.ok(self.tx(rect_sql(t, p, self.f("ward"), 10, 6, 20, 10)))   # 200 m² calculados
        # sin umbral configurado no hay veredicto
        self.ok(f"UPDATE practice.care_spaces SET area_m2 = 150 WHERE id='{self.f('ward')}';", system=True)
        self.assertEqual(self.ok(f"SELECT deviation_pct || '|' || coalesce(within_tolerance::text,'null') FROM practice.v_floor_plan_spaces WHERE care_space_id='{self.f('ward')}'", system=True), "33.33|null")
        self.assertEqual(self.ok(f"SELECT count(*) FROM practice.plan_validate('{p}')", system=True), "0")
        # con umbral configurado (dato en practice_settings) aparece la advertencia
        self.ok("SET app.system_context='true';\nSET session_replication_role = replica;\n"
                f"INSERT INTO practice.practice_settings (id, practice_id, setting_key, value_json, created_at, updated_at) "
                f"VALUES (gen_random_uuid(), '{self.f('practice')}', 'infra.plan.area_tolerance_pct', '10', now(), now()) "
                "ON CONFLICT DO NOTHING;")
        out = self.ok(f"SELECT severity || ':' || code FROM practice.plan_validate('{p}')", system=True)
        self.assertEqual(out, "WARNING:AREA_MISMATCH")
        # espacios sin ubicar: ward ya está; quedan roomA, roomB, bed1, bed2 (hijos de ward) — `extra` también (hijo del ancla)
        un = self.ok(f"SELECT count(*) FROM practice.plan_unplaced_spaces('{p}')", system=True)
        self.assertEqual(un, "5")
        self.assertEqual(self.ok(f"SELECT depth FROM practice.plan_unplaced_spaces('{p}') ORDER BY depth DESC LIMIT 1", system=True), "3")
        self.ok(f"UPDATE practice.care_spaces SET area_m2 = NULL WHERE id='{self.f('ward')}';", system=True)

    def test_27_gist_serves_viewport_queries(self) -> None:
        self.clean_plan()
        self.ok(self.tx(rect_sql(self.ta, self.f("plan"), self.f("ward"), 10, 6, 20, 10)))
        n = self.ok(f"SELECT count(*) FROM practice.space_placements WHERE floor_plan_id='{self.f('plan')}' AND bbox && box(point(0,0), point(5,5))", system=True)
        self.assertEqual(n, "1")
        # el índice existe y es utilizable por la consulta de ventana (aunque el planificador elija otro si la tabla es chica)
        plan = self.ok("SET enable_seqscan = off;\nSET enable_bitmapscan = off;\nSET enable_indexscan = on;\n"
                       "EXPLAIN SELECT 1 FROM practice.space_placements WHERE floor_plan_id = gen_random_uuid() AND bbox && box(point(0,0), point(5,5));")
        self.assertIn("Index", plan)
        self.assertIn("USING gist", self.ok("SELECT indexdef FROM pg_indexes WHERE indexname = 'gist_space_placements_plan_bbox'", system=True))
    # ---- 12. escala: un piso grande (1.600 locales pegados entre sí, como un hospital de varias alas)
    def test_28_large_floor_loads_validates_and_serves_viewport_queries(self) -> None:
        import time
        t = self.ta
        lvl, plan = str(uuid.uuid4()), str(uuid.uuid4())
        self.ok("SET app.system_context='true';\nSET session_replication_role = replica;\nBEGIN;\n"
                f"INSERT INTO practice.care_spaces (id, practice_site_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
                f"VALUES ('{lvl}', '{self.f('site')}', 'BIG-{lvl[:6]}', 'Piso grande', '{lvl}', '{lvl}', now(), now(), '{t}');\n"
                f"INSERT INTO practice.care_spaces (id, practice_site_id, parent_space_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
                f"SELECT gen_random_uuid(), '{self.f('site')}', '{lvl}', 'BIG-{lvl[:6]}-' || g, 'Local ' || g, '{lvl}', '{lvl}', now(), now(), '{t}' "
                f"FROM generate_series(0, 1599) g;\n"
                f"INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, created_at, updated_at) "
                f"VALUES ('{plan}', '{t}', '{self.f('site')}', '{lvl}', 'BIGP-{plan[:6]}', 'Piso grande', 125, 125, now(), now());\nCOMMIT;")
        started = time.monotonic()
        self.ok("SET app.system_context='true';\nBEGIN;\n"
                f"INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, center_x_m, center_y_m, width_m, depth_m, rotation_deg, vertices) "
                f"SELECT gen_random_uuid(), '{t}', '{plan}', c.id, 'RECT', 2.5 + 3 * (n % 40), 2.5 + 3 * (n / 40), 3, 3, 0, '[]' "
                f"FROM (SELECT id, (row_number() OVER (ORDER BY code) - 1)::int AS n FROM practice.care_spaces WHERE parent_space_id = '{lvl}') c;\nCOMMIT;")
        load_s = time.monotonic() - started
        self.assertEqual(self.ok(f"SELECT count(*) FROM practice.space_placements WHERE floor_plan_id='{plan}'", system=True), "1600")
        self.assertLess(load_s, 60, f"carga de 1600 locales tardó {load_s:.1f} s")
        started = time.monotonic()
        self.assertEqual(self.ok(f"SELECT count(*) FROM practice.plan_validate('{plan}')", system=True), "0")
        validate_s = time.monotonic() - started
        self.assertLess(validate_s, 30, f"plan_validate de 1600 locales tardó {validate_s:.1f} s")
        # una ventana de 12 × 12 m trae 16 locales y usa el índice gist (con enable_seqscan apagado no hay otra opción)
        win = f"floor_plan_id = '{plan}' AND bbox && box(point(30,30), point(42,42))"
        self.assertEqual(self.ok(f"SELECT count(*) FROM practice.space_placements WHERE {win}", system=True), "25")  # 16 dentro + 9 que la tocan
        self.ok("ANALYZE practice.space_placements;", system=True)
        explain = self.ok(f"EXPLAIN SELECT 1 FROM practice.space_placements WHERE {win};", system=True)
        self.assertNotIn("Seq Scan", explain, explain)  # con estadísticas al día, la ventana usa un índice (gist) y no recorre el piso
        print("\n[plano] ventana 12x12 m:", explain.splitlines()[0].strip())
        # un solape en el piso grande lo sigue encontrando el EXCLUDE sin recorrer los 1600
        one = self.ok(f"SELECT care_space_id FROM practice.space_placements WHERE floor_plan_id='{plan}' LIMIT 1", system=True)
        started = time.monotonic()
        self.fails(self.tx(f"UPDATE practice.space_placements SET center_x_m = center_x_m + 1.5 WHERE care_space_id='{one}';"),
                   "ex_space_placements_no_overlap")
        self.assertLess(time.monotonic() - started, 5)
        print(f"\n[plano] 1600 locales: carga {load_s:.2f} s · plan_validate {validate_s:.2f} s")



SEED_FUNCTIONS = ("CONSULTING_ROOM EMERGENCY_BOX PROCEDURE_ROOM OBSERVATION IMAGING_ROOM WAITING OFFICE_ADMIN SAMPLE_COLLECTION "
                  "LAB_AREA PHARMACY STORAGE INPATIENT_ROOM ISOLATION_AIIR NURSE_STATION OPERATING_ROOM RECOVERY_PACU STERILIZATION "
                  "DELIVERY_ROOM ICU_BAY BED_STANDARD BED_ICU BUILDING_GENERIC LEVEL_GENERIC WARD_GENERIC AREA_GENERIC").split()
SEED_FORMS = "BUILDING LEVEL WARD AREA ROOM BED".split()


@unittest.skipIf(_db_available() is not None, f"base de pruebas no disponible: {_db_available()}")
class LiveSeedTests(unittest.TestCase):
    """Carga el plano del hospital de ejemplo sobre una sede nueva, dos veces, y lo valida."""

    @classmethod
    def setUpClass(cls) -> None:
        u = lambda: str(uuid.uuid4())  # noqa: E731
        cls.tenant, cls.practice, cls.site, c = u(), u(), u(), u()
        codes = [f"practice:SPACE_FN_{f}" for f in SEED_FUNCTIONS] + [f"practice:LOC_FORM_{f}" for f in SEED_FORMS]
        codes += ["practice:SPACE_ACTIVE", "practice:UNIT_ACTIVE", "practice:UNIT_TYPE_TEST", "practice:SPACE_UNIT_ROLE_OWNER"]
        lines = ["SET app.system_context = 'true';", "SET session_replication_role = replica;"]
        for code in codes:
            lines.append(f"INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, created_at, updated_at) "
                         f"SELECT gen_random_uuid(), '{c}', '{code}', '{code}', now(), now() WHERE NOT EXISTS "
                         f"(SELECT 1 FROM terminology.catalog_concepts WHERE code = '{code}');")
        lines += [
            f"INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, legal_entity_type_concept_id, status_concept_id, "
            f"verification_status_concept_id, created_at, updated_at) VALUES ('{cls.tenant}', 'T-{cls.tenant[:8]}', '{c}', 'Demo plano', '{c}', '{c}', '{c}', now(), now());",
            f"INSERT INTO practice.practices (id, tenant_id, code, name, type_concept_id, admin_user_id, status_concept_id, created_at, updated_at) "
            f"VALUES ('{cls.practice}', '{cls.tenant}', 'P-{cls.practice[:8]}', 'Demo', '{c}', '{u()}', '{c}', now(), now());",
            f"INSERT INTO practice.practice_sites (id, practice_id, code, name, site_type_concept_id, status_concept_id, created_at, updated_at, tenant_id) "
            f"VALUES ('{cls.site}', '{cls.practice}', 'S-{cls.site[:8]}', 'Hospital demo', '{c}', '{c}', now(), now(), '{cls.tenant}');",
        ]
        rc, _, err = _psql("\n".join(lines))
        if rc != 0:
            raise RuntimeError(f"fixture del seed falló: {err}")

    def seed(self) -> subprocess.CompletedProcess:
        return subprocess.run(["psql", DSN, "-X", "-q", "-v", "ON_ERROR_STOP=1", "-v", f"site_id={self.site}", "-f", str(SEED)],
                              capture_output=True, text=True, timeout=300)

    def q(self, sql: str) -> str:
        rc, out, err = _psql(sql, system=True)
        self.assertEqual(rc, 0, err)
        return out

    def counts(self) -> str:
        return self.q(f"""SELECT (SELECT count(*) FROM practice.care_spaces WHERE practice_site_id='{self.site}') || '/' ||
                                 (SELECT count(*) FROM practice.floor_plans WHERE practice_site_id='{self.site}') || '/' ||
                                 (SELECT count(*) FROM practice.space_placements sp JOIN practice.floor_plans fp ON fp.id=sp.floor_plan_id WHERE fp.practice_site_id='{self.site}') || '/' ||
                                 (SELECT count(*) FROM practice.plan_elements e JOIN practice.floor_plans fp ON fp.id=e.floor_plan_id WHERE fp.practice_site_id='{self.site}') || '/' ||
                                 (SELECT count(*) FROM practice.clinical_units WHERE practice_site_id='{self.site}') || '/' ||
                                 (SELECT count(*) FROM practice.space_unit_assignments WHERE tenant_id='{self.tenant}')""")

    def test_seed_loads_twice_without_changes_and_validates(self) -> None:
        first = self.seed()
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertIn("0 errores de validación", first.stderr)
        after_first = self.counts()
        second = self.seed()
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(self.counts(), after_first, "la segunda carga cambió datos")
        spaces, plans, placements, elements, units, assignments = (int(x) for x in after_first.split("/"))
        self.assertEqual((plans, units), (3, 12))
        self.assertEqual((spaces, placements, elements), (88, 86, 136))  # los dos pisos son lienzos, no figuras
        self.assertGreater(assignments, 40)

    def test_seed_plan_is_architecturally_coherent(self) -> None:
        self.seed()
        # los dos desvíos de área a propósito, y sólo ésos
        self.assertEqual(
            self.q(f"SELECT string_agg(v.code || ':' || v.deviation_pct, ',' ORDER BY v.code) FROM practice.v_floor_plan_spaces v "
                   f"JOIN practice.floor_plans fp ON fp.id=v.floor_plan_id WHERE fp.practice_site_id='{self.site}' AND v.within_tolerance = false"),
            "PLANO-P1-QX2:14.86,PLANO-PB-C3:13.33")
        warn = self.q(f"SELECT count(*) FROM practice.floor_plans fp CROSS JOIN LATERAL practice.plan_validate(fp.id) v "
                      f"WHERE fp.practice_site_id='{self.site}' AND v.severity='WARNING' AND v.code='AREA_MISMATCH'")
        self.assertEqual(warn, "2")
        self.assertEqual(self.q(f"SELECT count(*) FROM practice.floor_plans fp CROSS JOIN LATERAL practice.plan_validate(fp.id) v "
                                f"WHERE fp.practice_site_id='{self.site}' AND v.severity='ERROR'"), "0")
        # nada sin ubicar en los pisos (el estacionamiento y el edificio sí están en el campus)
        self.assertEqual(self.q(f"SELECT count(*) FROM practice.floor_plans fp CROSS JOIN LATERAL practice.plan_unplaced_spaces(fp.id) u "
                                f"WHERE fp.practice_site_id='{self.site}' AND fp.code <> 'PLANO-CP'"), "0")
        # 30 camas, todas dentro de su habitación (restricción diferida ya verificada) y con área calculada 2 m²
        self.assertEqual(self.q(f"SELECT count(*) || '|' || min(sp.area_calc_m2) || '|' || max(sp.area_calc_m2) FROM practice.space_placements sp "
                                f"JOIN practice.care_spaces cs ON cs.id=sp.care_space_id WHERE cs.practice_site_id='{self.site}' AND cs.censable"),
                         "30|2.000|2.000")
        # cada puerta cabe en su muro y cada ventana en el muro exterior
        self.assertEqual(self.q(f"SELECT count(*) FROM practice.plan_elements d JOIN practice.plan_elements w ON w.id=d.host_element_id "
                                f"JOIN practice.floor_plans fp ON fp.id=d.floor_plan_id WHERE fp.practice_site_id='{self.site}' "
                                f"AND d.offset_m + d.width_m > practice.plan_polyline_length(w.vertices) + 0.001"), "0")
        # escalera y ascensor enlazan los dos pisos con el mismo código
        self.assertEqual(self.q(f"SELECT string_agg(DISTINCT vertical_link_code || '=' || n, ',' ORDER BY vertical_link_code || '=' || n) FROM ("
                                f"SELECT e.vertical_link_code, count(*) n FROM practice.plan_elements e JOIN practice.floor_plans fp ON fp.id=e.floor_plan_id "
                                f"WHERE fp.practice_site_id='{self.site}' AND e.vertical_link_code IS NOT NULL GROUP BY 1) q"), "ASC-1=2,ESC-A=2")
        # layout_version coherente: una subida por la carga de cada lienzo
        self.assertEqual(self.q(f"SELECT string_agg(code || '=' || layout_version, ',' ORDER BY code) FROM practice.floor_plans WHERE practice_site_id='{self.site}'"),
                         "PLANO-CP=2,PLANO-P1=2,PLANO-PB=2")


if __name__ == "__main__":
    unittest.main()
